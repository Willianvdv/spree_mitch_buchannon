class AddReminderThresholdToPaymentMethod < ActiveRecord::Migration
  def change
    add_column :spree_payment_methods, :reminder_threshold, :integer, default: 1
  end
end
