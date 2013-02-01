$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sagepay_server/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sagepay_server"
  s.version     = SagepayServer::VERSION
  s.authors     = ["Tom Beynon"]
  s.email       = ["tbeynon@rawnet.com"]
  s.homepage    = "http://www.rawnet.com"
  s.summary     = "Abstraction of Sagepay Server payment handling"
  s.description = "Abstraction of Sagepay Server payment handling. Currently only handles the PAYMENT transaction type"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.1.0"
end
