class AddOnTotalToOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :add_on_total, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
