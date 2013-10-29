class AddPaymentReminderSentAtToOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :payment_reminder_sent_at, :datetime
  end
end
