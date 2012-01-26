module BillingSystemModels
  module Invoices
    def self.included(base)
      base.module_eval do
        has_many :invoices
        has_many :payments

        include InstanceMethods
      end
    end

    module InstanceMethods
      def bill_to
        begin
          super
        rescue NoMethodError
          nil
        end
      end
    end
  end
end
