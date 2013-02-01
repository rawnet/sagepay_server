################################################################################################
### Accepts a POST notification from Sagepay once the user has entered their payment details ###
################################################################################################

class SagepayNotificationsController < ApplicationController
	
	def create
		# Find transaction and update from Sagepay's post
		sagepay_transaction = SagepayTransaction.record_notification_from_params(params)
		# Render the payment status in a Sagepay readable format
		render :text => notification_response_text(sagepay_transaction.response_hash(payment_url(sagepay_transaction.payment)))
	rescue Exception => e
  	# Something serious went wrong when updating the Sagepay transaction
  	flash[:alert] = "An error occurred with your payment. Please try again or contact us"
    render :text => notification_response_text(:status => :error, :status_detail => "An error occurred: #{e.message}", :redirect_url => payments_url)
	end
	
protected

	def notification_response_text(*args)
		options = args.extract_options!
		# Sagepay always expects these parameters
		params = [
			["Status", options[:status].to_s.upcase],
			["RedirectURL", options[:redirect_url]]
		]
		# Only add statusDetail if we need it
		params << ["StatusDetail", options[:status_detail]] if options[:status_detail].present?

		# Now process our array and format it in a way Sagepay expects
		sagepay_response = params.map do |key, value|
      "#{key}=#{value}"
    end
    
    sagepay_response.join("\r\n")
    
	end
	
end