class CreateSagepayTransactions < ActiveRecord::Migration
  def change
    create_table :sagepay_transactions do |t|
    	t.references :payment
      t.string :vendor_tx_code
      t.string :tx_type
      t.decimal :amount
      t.string :currency
      t.string :vps_tx_id
      t.string :security_key
      t.string :status
      t.string :tx_auth_no
      t.boolean :avs_cv2_matched
      t.boolean :address_matched
      t.boolean :postcode_matched
      t.boolean :cv2_matched
      t.boolean :gift_aid
      t.boolean :threed_secure_ok
      t.string :card_type
      t.string :last_4_digits

      t.timestamps
    end
  end
end
