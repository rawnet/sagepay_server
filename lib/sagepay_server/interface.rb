module SagepayServer
	class Interface
		include ActiveModel::Validations
		
		class_attribute :vps_protocol, :tx_type
		
		self.vps_protocol = "2.23"
		
		attr_accessor :mode, :vendor, :vendor_tx_code
		
		validates :vps_protocol, :tx_type, :mode, :vendor, :vendor_tx_code, :presence => true
		
		validates :mode, :inclusion => {:in => [:simulator, :test, :live]}
		
		def initialize(attributes = {})
      attributes.each do |k, v|
        send("#{k}=", v)
      end
    end
		
		def post_params
			raise ArgumentError, "Invalid transaction registration options (see errors hash for details)" unless valid?
			params = {
				"VPSProtocol" => vps_protocol,
	      "TxType" => tx_type,
	      "Vendor" => vendor,
	      "VendorTxCode" => vendor_tx_code
			}
			params
		end
		
	end
end