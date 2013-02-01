class Payment < ActiveRecord::Base
  
  # Your model relationships
  
  belongs_to :billing_address, :class_name => "PaymentAddress", :dependent => :destroy
  belongs_to :delivery_address, :class_name => "PaymentAddress", :dependent => :destroy
  
  has_many :sagepay_transactions, :dependent => :destroy
  has_one :latest_sagepay_transaction, :class_name => "SagepayTransaction", :order => "created_at DESC"
  
  accepts_nested_attributes_for :billing_address, :delivery_address
  
  validates :email, :billing_address, :presence => true
  
  # Any other validations
  
  scope :latest, order("created_at DESC").limit(1)
  
  def update_details(payment_params)
  	billing_params = payment_params[:billing_address_attributes]
  	delivery_params = payment_params[:delivery_address_attributes]
  	
  	self.attributes = ({
	  	:email => payment_params[:email]
	  	# Remember to set any additional fields here (such as relationships)
  	})
  	self.billing_address ||= PaymentAddress.new
  	self.billing_address.attributes = billing_params
  	
  	if payment_params[:same_as_billing].present?
  		self.delivery_address = nil
  	else
  		self.delivery_address ||= PaymentAddress.new
  		self.delivery_address.attributes = delivery_params
  	end
  	
  	self
  end
  
  def text_status
  	if success?
  		"paid"
  	else
  		"unpaid"
  	end
  end
  
  def started?
  	latest_sagepay_transaction.present?
  end
  
  def active?
  	!started? || (started? && !success?)
  end
  
  def inactive?
  	!active?
  end
  
  def success?
  	started? && latest_sagepay_transaction.success?
  end
  
  def delivery_same_as_billing?
  	delivery_address.nil?
  end
  
end
