namespace :mitch  do
  desc 'send unconfirmed orders a mail to complete the order'
  task send_order_completion_motivation_emails: :environment do
    Rails.logger.info 'Send motivation mail to complete the order'
    Spree::Order.send_motivation_emails
  end

  desc 'send payment reminders to unpaid orders'
  task send_reminder_emails: :environment do
    Rails.logger.info 'Send payment reminder emails to unpaid orders'
    Spree::Order.send_payment_reminder_emails_to_unpaid_orders
  end

  desc 'cancel old unpaid orders'
  task cancel_unpaid_orders: :environment do
    Rails.logger.info 'Cancelling unpaid order older than 30 days'
    Spree::Order.cancel_cancellation_candidates
  end
end
