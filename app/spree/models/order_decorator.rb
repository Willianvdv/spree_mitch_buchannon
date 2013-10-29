Spree::Order.class_eval do
  def self.payment_reminder_candidates
    self.complete.where('payment_reminder_sent_at is null')
  end
end