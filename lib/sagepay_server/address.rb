module SagepayServer
	class Address
		include ActiveModel::Validations
		
		attr_accessor :first_names, :surname, :address_1, :address_2, :city, :state, :postcode, :country, :phone
		
		validates :first_names, :surname, :address_1, :city, :postcode, :country, :presence => true
		
		validates :country, :state, :length =>  {:maximum => 2}
		
		validates :state, :presence => {:message => "is required if you're from the US"}, :if => :in_us?
		validates :state, :inclusion => {:in => ['', nil], :mesage => "should not be entered if you're not in the US"}, :unless => :in_us?
		
		def initialize(attributes = {})
      attributes.each do |k, v|
        send("#{k}=", v)
      end
    end
    
    def in_us?
    	country == "US"
    end
		
	end
end