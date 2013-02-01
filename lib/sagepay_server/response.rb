module SagepayServer
	class Response
	
		class_attribute :key_converter, :value_converter, :match_converter, :instance_writer => false
		
		attr_accessor :vps_protocol, :status, :status_detail,
									:vps_tx_id, :security_key, :next_url
		
		self.key_converter = {
			"VPSProtocol" => :vps_protocol,
      "Status" => :status,
      "StatusDetail" => :status_detail,
      "VPSTxId" => :vps_tx_id,
      "SecurityKey" => :security_key,
      "NextURL" => :next_url
    }
    
    self.value_converter = {
      :status => {
        "OK" => :ok,
        "MALFORMED" => :malformed,
        "INVALID" => :invalid,
        "ERROR" => :error
      }
    }
    
    self.match_converter = {
      "NOTPROVIDED" => :not_provided,
      "NOTCHECKED" => :not_checked,
      "MATCHED" => :matched,
      "NOTMATCHED" => :not_matched
    }
    
    def self.from_response_body(response_body)
			response_attributes = {}
			response_body.each_line do |line|
				key, value = line.split("=", 2)
				unless key.nil? || value.nil?
					key = key_converter[key]
					value = value.chomp
					value = value_converter[key] ? value_converter[key][value] : value
					response_attributes[key] = value
				end
			end
			new(response_attributes)
		end
		
		def ok?
			status == :ok
		end
		
		def initialize(attributes = {})
      attributes.each do |k, v|
        send("#{k}=", v)
      end
    end
		    
	end
end