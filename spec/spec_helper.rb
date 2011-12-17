$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'init'

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

require 'spec/mocks'

require 'factory_girl'
require 'spec/factories.rb'

config = YAML::load(File.open('spec/database.yml'))
ActiveRecord::Base.establish_connection(config)

Spec::Runner.configure do |config|
  # Can't figure out how to get this to work
  #
  # I always get::
  #
  #   undefined method `use_transactional_fixtures=' for #<Spec::Runner::Configuration:0x7fa8fa8cf2d0> (NoMethodError)
  #
  # config.use_transactional_fixtures = true
end

Spec::Mocks::Proxy.allow_message_expectations_on_nil

class Account < ActiveRecord::Base
  def sold_to
    <<-EOF
John Doe
111 Example Ln.
Nowhere
    EOF
  end
end

# Include when needed
#
# require 'ruby-debug'
