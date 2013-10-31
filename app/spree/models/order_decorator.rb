Spree::Order.class_eval do
  def self.payment_reminder_candidates
    self.complete
      .where('payment_reminder_sent_at is null')
      .where(completed_at: 1.days.ago..1.hour.ago)
  end

  def self.cancellation_candidates 
    self.complete.where("payment_state != 'paid'").where("completed_at < ?", 2.days.ago)
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

  # todo: don't think this method should be on the model
  def self.send_payment_reminder_emails_to_unpaid_orders
    payment_reminder_candidates.each do |payment_reminder_candidate|
      payment_reminder_candidate.send_payment_reminder_email
    end
  end
end