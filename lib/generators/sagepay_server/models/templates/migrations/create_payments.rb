class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.text :email
      t.references :billing_address
      t.references :delivery_address

      t.timestamps
    end
    add_index :payments, :billing_address_id
    add_index :payments, :delivery_address_id
  end
end
