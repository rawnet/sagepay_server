#############################################################
### Creates a Sagepay transaction for the current payment ###
#############################################################

class SagepayTransactionsController < ApplicationController
	
	def create
		payment = Payment.find_by_id(params[:payment_id].to_i)
  	raise "Not found" if payment.nil? || payment.success?
  	sagepay_transaction = payment.sagepay_transactions.new({
  		:vendor           => "VENDOR",   # Your vendor name here
  		:mode             => :simulator, # :simulator, :test, :live
	  	:tx_type          => "PAYMENT",  # Currently only works with PAYMENT. Could be REFUND, AUTHORISE etc
	  	:amount           => 10.00,      # Payment amount. This should probably be moved back to Payment instead of SagepayTransaction
	  	:currency         => "GBP",      # GBP, USD etc
	  	:description      => "Order description", # The order description, as shown on the payment page (we're using LOW templates [in-frame], so this won't show)
	  	:notification_url => sagepay_notifications_url # Our Sagepay notifications URL
  	})
  	next_url = sagepay_transaction.pay # Tell our model to start the payment process
  	if next_url
  		# We now have the URL of the payment page.
  		# We load our sagepay 'pay' page, and display the payment page in a frame
  		session[:next_url] = next_url
  		redirect_to payment_sagepay_pay_path(payment)
  	else
  		# We don't have a payment page. FAIL
  		flash[:error] = "There was a problem redirecting you to our payment provider"
  		redirect_to payment
  	end
	end
	
	# Displays the URL we've been given from Sagepay in a frame
	def pay
		payment = Payment.find_by_id(params[:payment_id].to_i)
		next_url = session[:next_url]
		render_404 if payment.nil?
		if next_url.nil?
			flash[:error] = "There was a problem redirecting you to our payment provider"
			redirect_to payment 
		end
		if payment.success?
			flash[:error] = "This order has already been paid"
			redirect_to payment 
		end
  	render :locals => {:next_url => next_url, :payment => payment}
	end
	
end