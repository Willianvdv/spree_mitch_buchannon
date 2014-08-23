Spree::Order.class_eval do
  def self.payment_reminder_candidates

    # Gives a set with orders where the user has not placed any new orders
    orders = \
      self.complete
          .select(
            '(select count(*) from spree_orders as SO ' +
            'where SO.user_id == spree_orders.user_id and '+
            'SO.id != spree_orders.id and ' +
            'SO.completed_at > spree_orders.completed_at) as future_orders, ' +
            '*')
          .where('payment_reminder_sent_at is null')
          .where('future_orders == 0')
          .to_a

    # The reminder threshold is dynamic. Doing it in a query would be super complex (I think)
    orders = orders.keep_if do |order|
      reminder_threshold = order.payments.last.try(:reminder_threshold) || 1

      order.completed_at > (reminder_threshold + 24).hour.ago &&
      order.completed_at < (reminder_threshold).hour.ago
    end

    orders
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

  # Override!
  def send_cancel_email
    if completed_at > 30.days.ago
      Spree::OrderMailer.cancel_email(self.id).deliver
    else
      Rails.logger.info "Won't send cancel email because order is older than 30 days"
    end
  end
end
