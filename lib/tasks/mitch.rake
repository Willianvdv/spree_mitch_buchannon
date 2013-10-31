namespace :mitch  do
  desc "send payment reminders to unpaid orders"
  task :send_reminder_emails do
    Spree::Order.send_payment_reminder_emails_to_unpaid_orders
  end

  desc "cancel old unpaid orders"
  task :cancel_unpaid_orders do
    raise "Sorry, not implemented yet!"
  end
end