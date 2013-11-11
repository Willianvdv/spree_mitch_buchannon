Spree::Order.class_eval do
  def self.payment_reminder_candidates
    self.complete
      .select('(select count(*) from spree_orders as SO ' +
              'where SO.user_id == spree_orders.user_id and '+
              'SO.id != spree_orders.id and ' +
              'SO.completed_at > spree_orders.completed_at) as future_orders, ' +
              '*')
      .where('payment_reminder_sent_at is null')
      .where(completed_at: 1.days.ago..1.hour.ago)
      .where('future_orders == 0')
  end

  def self.cancellation_candidates 
    self.complete
      .where("payment_state != 'paid'")
      .where("completed_at < ?", 2.days.ago)
      .where("state != 'canceled'")
  end

  def send_payment_reminder_email
    touch(:payment_reminder_sent_at)
    message = Spree::PaymentReminderMailer.payment_reminder_email(self)
    message.deliver!
  end

  def self.cancel_cancellation_candidates
    cancellation_candidates.each do |cancellation_candidate|
      cancellation_candidate.cancel!
    end
  end

  def self.send_payment_reminder_emails_to_unpaid_orders
    payment_reminder_candidates.each do |payment_reminder_candidate|
      payment_reminder_candidate.send_payment_reminder_email
    end
  end

  # Almost identical to the original after_cancel except
  # the original will send cancel_emails for old orders
  def after_cancel
    restock_items!
    #TODO: make_shipments_pending

    # Addition: Don't send if order is older than 30 days
    if completed_at > 30.days.ago
      Spree::OrderMailer.cancel_email(self.id).deliver
    else
      Rails.logger.info "Won't send cancel email because order is older than 30 days"
    end

    unless %w(partial shipped).include?(shipment_state)
      self.payment_state = 'credit_owed'
    end
  end
end