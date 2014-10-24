Spree::Order.class_eval do
  def self.payment_reminder_candidates
    orders = Spree::Order.complete
              .where("(payment_state is null OR payment_state != 'paid')")
              .where("(payment_reminder_sent_at is null or payment_reminder_sent_at == '')")

    orders.keep_if do |order|
      future_orders = Spree::Order.where('completed_at > ?', order.completed_at)
                                  .where(user: order.user)

      reminder_threshold = (order.payments.last.try(:payment_method).try(:reminder_threshold) || 1).hours.ago

      min = reminder_threshold - 1.days
      max = reminder_threshold

      future_orders.empty? && order.completed_at.between?(min, max)
    end
  end

  def self.cancellation_candidates
    cancellation_canditates = complete
                                .where("payment_state != 'paid'")
                                .where("state != 'canceled'")

    cancellation_canditates.keep_if do |order|
      reminder_threshold = ((order.payments.last.try(:payment_method).try(:reminder_threshold) || 1) * 3).hours.ago

      order.completed_at < reminder_threshold
    end
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
