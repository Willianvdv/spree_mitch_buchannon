Spree::Order.class_eval do
  def self.payment_reminder_candidates
    self.complete
  end
end