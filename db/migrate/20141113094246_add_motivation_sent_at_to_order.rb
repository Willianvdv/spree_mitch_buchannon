class AddMotivationSentAtToOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :motivation_sent_at, :datetime
  end
end
