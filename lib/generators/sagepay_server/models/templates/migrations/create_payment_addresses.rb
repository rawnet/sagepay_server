class CreatePaymentAddresses < ActiveRecord::Migration
  def change
    create_table :payment_addresses do |t|
      t.string :firstname
      t.string :surname
      t.text :address_1
      t.text :address_2
      t.string :city
      t.string :state
      t.string :postcode
      t.string :country
      t.string :phone

      t.timestamps
    end
  end
end
