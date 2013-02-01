####################################
### CRUD methods for the payment ###
####################################

class PaymentsController < ApplicationController
  
  def index
  	
  end
  
  def show
  	payment = Payment.find(params[:id].to_i)
  	
  	# If payment has been attempted before, and the latest payment failed, show a notice
  	if payment.started? && payment.latest_sagepay_transaction.failed?
  		flash.now[:error] = "Your most recent payment failed. Please try again"
  	end
  	
  	render :locals => {:payment => payment}
  end
  
  def new
  	payment = Payment.new
  	payment.build_billing_address
  	payment.build_delivery_address
  	render :locals => {:payment => payment}
  end
  
  def edit
  	payment = current_user.payments.find(params[:id].to_i)
  	raise "Not found" if payment.nil? || payment.inactive? # Don't let them edit inactive payments
  	
  	payment.build_delivery_address if payment.delivery_address.nil?
  	
  	render :locals => {:payment => payment}
  end
  
  def create
  	payment = Payment.new
  	payment.update_details(params[:payment])
  	
  	if payment.save
  		redirect_to payment
  	else
  		payment.build_delivery_address if payment.delivery_address.nil?
	  	render :edit, :locals => {:payment => payment}
  	end 
  end
  
  def update
  	payment = current_user.payments.find(params[:id].to_i)
  	raise "Not found" if payment.nil? || payment.inactive?
  	payment.update_details(params[:payment])
  	if payment.save
  		redirect_to payment
  	else
  		payment.build_delivery_address if payment.delivery_address.nil?
	  	render :edit, :locals => {:payment => payment}
  	end
  end
  
end