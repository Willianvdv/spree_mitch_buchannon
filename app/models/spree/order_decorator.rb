Spree::Order.class_eval do
  # Override!
  def send_cancel_email
    if completed_at > 30.days.ago
      Spree::OrderMailer.cancel_email(self.id).deliver
    else
      Rails.logger.info "Refused sending cancel email because the order is older than 30 days"
    end
  end

  def future_orders?
    self.class
      .where('completed_at > ?', completed_at)
      .where(email: email)
      .any?
  end

  def send_motivation_email
    touch :motivation_sent_at
    Spree::MotivationMailer.motivation_email(self).deliver!
  end

  def send_payment_reminder_email
    touch :payment_reminder_sent_at
    Spree::PaymentReminderMailer.payment_reminder_email(self).deliver!
  end
end
