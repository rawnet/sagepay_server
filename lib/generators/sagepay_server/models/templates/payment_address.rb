class PaymentAddress < ActiveRecord::Base
	belongs_to :payment
	
	attr_accessible :firstname, :surname, :address_1, :address_2, :city, :state, :postcode, :country, :phone
	
	validates :firstname, :surname, :address_1, :city, :postcode, :country, :presence => true
	
	validates :country, :length => {:maximum => 2} # Country must be in 2 character format, e.g. GB, US, AF etc
	validates :state, :length => {:maximum => 2, :allow_blank => true} # State must be in 2 character format, e.g. CA, NY, NJ etc
	
	# State only applies to US orders. MUST be blank otherwise
	validates :state, :presence => {:message => "is required if you're from the US"}, :if => :in_us?
	validates :state, :inclusion => {:in => ['', nil], :mesage => "should not be entered if you're not in the US"}, :unless => :in_us? 
	
	def to_sagepay_server_address
		SagepayServer::Address.new({
			:first_names => firstname,
			:surname => surname,
			:address_1 => address_1,
			:address_2 => address_2,
			:city => city,
			:state => state,
			:postcode => postcode,
			:country => country,
			:phone => phone
		})
	end
	
	def in_us?
  	country == "US"
  end
	
end
