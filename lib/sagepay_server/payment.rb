module SagepayServer
	class Payment < Interface
		
		attr_accessor :amount, :currency, :description, :notification_url, :profile, 
									:billing_address, :delivery_address, :customer_email,
									:basket, :allow_gift_aid, :apply_avs_cv2, :apply_3d_secure, :billing_agreement
									
		validates :amount, :currency, :description, :notification_url, :billing_address, :delivery_address, :presence => true
		
		def run_payment!
			handle_response(run_post)
		end
		
		def url
      case mode
      when :simulator
        "https://test.sagepay.com/simulator/VSPServerGateway.asp?Service=VendorRegisterTx"
      when :test
        "https://test.sagepay.com/gateway/service/vspserver-register.vsp"
      when :live
        "https://live.sagepay.com/gateway/service/vspserver-register.vsp"
      end
    end
		
		def post_params
			params = super.merge({
				"Amount" => ("%.2f" % amount),
	      "Currency" => currency,
	      "Description" => description,
	      "NotificationURL" => notification_url,
	      "BillingSurname" => billing_address.surname,
	      "BillingFirstnames" => billing_address.first_names,
	      "BillingAddress1" => billing_address.address_1,
	      "BillingCity" => billing_address.city,
	      "BillingPostCode" => billing_address.postcode,
	      "BillingCountry" => billing_address.country,
	      "DeliverySurname" => delivery_address.surname,
	      "DeliveryFirstnames" => delivery_address.first_names,
	      "DeliveryAddress1" => delivery_address.address_1,
	      "DeliveryCity" => delivery_address.city,
	      "DeliveryPostCode" => delivery_address.postcode,
	      "DeliveryCountry" => delivery_address.country
			})
	
			# Optional parameters
	    params['BillingAddress2'] = billing_address.address_2 if billing_address.address_2.present?
	    params['BillingState'] = billing_address.state if billing_address.state.present?
	    params['BillingPhone'] = billing_address.phone if billing_address.phone.present?
	    
	    params['DeliveryAddress2'] = delivery_address.address_2 if delivery_address.address_2.present?
	    params['DeliveryState'] = delivery_address.state if delivery_address.state.present?
	    params['DeliveryPhone'] = delivery_address.phone if delivery_address.phone.present?
	    
	    params['CustomerEmail'] = customer_email if customer_email.present?
	    
	    params['Basket'] = basket if basket.present?
	    params['AllowGiftAid'] = allow_gift_aid ? "1" : "0" if allow_gift_aid.present? || allow_gift_aid == false
	    params['ApplyAVSCV2'] = apply_avs_cv2.to_s if apply_avs_cv2.present?
	    params['Apply3DSecure'] = apply_3d_secure.to_s if apply_3d_secure.present?
	    params['Profile'] = profile.to_s.upcase if profile.present?
	    params['BillingAgreement'] = billing_agreement ? "1" : "0" if billing_agreement.present? || billing_agreement == false
	    #params['AccountType'] = account_type_param if account_type.present?
	    
	    params
		end

private
		
		# Thanks to Mathie's SagePay gem for the help with this bit!
		# https://github.com/mathie/sage_pay/blob/master/lib/sage_pay/server/command.rb#L79
		def run_post
			parsed_uri = URI.parse(url)
      request = Net::HTTP::Post.new(parsed_uri.request_uri)
      request.form_data = post_params

      http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)

      if parsed_uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.ca_file = '/etc/ssl/certs/ca-certificates.crt' if File.exists?('/etc/ssl/certs/ca-certificates.crt')
      end

      http.start { |http|
        http.request(request)
      }
		end
		
		def handle_response(response)
			case response.code.to_i
      when 200
        #response_from_response_body(response.body)
        Response.from_response_body(response.body)
      else
        raise RuntimeError, "Payment provider appears to be down. Please try again later."
      end
		end
		
	end
end