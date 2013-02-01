class SagepayTransaction < ActiveRecord::Base
	belongs_to :payment
	
	attr_accessor :description, :mode, :notification_url, :response, :notification
	
	validates :tx_type, :amount, :currency, :presence => true
	
	after_initialize do |sagepay_transaction|
		sagepay_transaction.assign_unique_vendor_tx_code if sagepay_transaction.vendor_tx_code.nil?
	end
	
	def self.record_notification_from_params(params)
		sagepay_transaction = nil
		notification = SagepayServer::Notification.from_params(params) do |attributes|
			sagepay_transaction = where(:vendor_tx_code => attributes[:vendor_tx_code], :vps_tx_id => attributes[:vps_tx_id]).first
			signature_verification = {
				:vendor => sagepay_transaction.vendor,
				:security_key => sagepay_transaction.security_key
			}
		end
		sagepay_transaction.update_attributes_from_notification(notification) if sagepay_transaction.present?
		sagepay_transaction
	end
	
	def assign_unique_vendor_tx_code
		generated_code = ""
		loop do # Why doesn't Ruby have a do..while loop?
			generated_code = generate_vendor_tx_code
			break if SagepayTransaction.where(:vendor_tx_code => generated_code).all.empty?
		end
		self.vendor_tx_code = generated_code
	end
	
	def generate_vendor_tx_code
		time = Time.now.strftime("%Y%m%d%M%S")
		random = Random.new.rand(1..32000) * Random.new.rand(1..32000)
		code = time+(random.to_s)
	end
	
	def pay
		raise RuntimeError, "Sagepay transaction already started for this payment" if payment.success?
		sagepay_payment = SagepayServer::Payment.new({
			:tx_type => "PAYMENT",
			:mode => mode, 
			:vendor => vendor, 
			:vendor_tx_code => vendor_tx_code,
			:amount => amount,
			:currency => currency,
			:description => description,
			:notification_url => notification_url,
			:profile => "LOW",
			:billing_address => payment.billing_address.to_sagepay_server_address,
			:delivery_address => (payment.delivery_address || payment.billing_address).to_sagepay_server_address,
			:customer_email => payment.email
		})
		self.response = sagepay_payment.run_payment!
		if response.ok?
			self.attributes = {
				:security_key => response.security_key,
				:vps_tx_id => response.vps_tx_id
			}
			self.save
			response.next_url
		else
			#raise response.status_detail.inspect
			nil
		end
	end
	
	def update_attributes_from_notification(notification)
		self.notification = notification
		if notification.valid_signature?
			update_attributes!({
				:status => notification.status.to_s,
				:tx_auth_no => notification.tx_auth_no,
				:avs_cv2_matched => notification.avs_cv2_matched?,
				:address_matched => notification.address_matched?,
        :postcode_matched => notification.post_code_matched?,
        :cv2_matched => notification.cv2_matched?,
        :gift_aid => notification.gift_aid,
        :threed_secure_ok => notification.threed_secure_status_ok?,
        :card_type => notification.card_type.to_s.humanize,
        :last_4_digits => notification.last_4_digits
			})
		else
			update_attributes!(:status => "tampered")
		end
	end
	
	def response_hash(redirect_url)
		notification.response_hash(redirect_url) if notification.present?
	end
	
	def complete?
		status.present?
	end
	
	def success?
		complete? && status == "ok"
	end
	
	def failed?
		complete? && !success?
	end
	
end
