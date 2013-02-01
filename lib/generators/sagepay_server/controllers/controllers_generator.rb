# Requires
require 'rails/generators'

module SagepayServer
	class ControllersGenerator < Rails::Generators::Base

		source_root File.expand_path('../templates', __FILE__)

    def copy_controllers
			copy_file "payments_controller.rb", "app/controllers/payments_controller.rb"
			copy_file "sagepay_transactions_controller.rb", "app/controllers/sagepay_transactions_controller.rb"
			copy_file "sagepay_notifications_controller.rb", "app/controllers/sagepay_notifications_controller.rb"
		end
		
	end
end