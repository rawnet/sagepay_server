# Requires
require 'rails/generators'
require 'rails/generators/migration'

module SagepayServer
	class ModelsGenerator < Rails::Generators::Base

		include Rails::Generators::Migration

		source_root File.expand_path('../templates', __FILE__)

		def self.next_migration_number(path)
      unless @prev_migration_nr
        @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
      else
        @prev_migration_nr += 1
      end
      @prev_migration_nr.to_s
    end

    def copy_models
			copy_file "payment.rb", "app/models/payment.rb"
			copy_file "payment_address.rb", "app/models/payment_address.rb"
			copy_file "sagepay_transaction.rb", "app/models/sagepay_transaction.rb"
		end

		def copy_migrations
			migration_template 'migrations/create_payments.rb', 'db/migrate/create_payments.rb'
			migration_template 'migrations/create_payment_addresses.rb', 'db/migrate/create_payment_addresses.rb'
			migration_template 'migrations/create_sagepay_transactions.rb', 'db/migrate/create_sagepay_transactions.rb'
		end
		
	end
end