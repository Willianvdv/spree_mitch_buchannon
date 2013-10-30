Spree::Order.class_eval do
  def self.payment_reminder_candidates
    self.complete
      .where('payment_reminder_sent_at is null')
      .where(completed_at: 1.days.ago..1.hour.ago)
  end

  def send_payment_reminder_email
    touch(:payment_reminder_sent_at)
    message = Spree::PaymentReminderMailer.payment_reminder_email(self)
    message.deliver!
  end

end