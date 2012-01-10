module BillingSystemModels
  module Sellable
    def self.included(base)
      base.module_eval do
        include InstanceMethods
        extend ClassMethods
      end
    end

    module ClassMethods
      def create_invoice(sellables, opts = {})
        # Coming soon!
      end
    end

    module InstanceMethods
      def description
        begin
          super
        rescue NoMethodError
          raise NotImplementedError.new("#{self.class}#description not implemented")
        end
      end

      def amount
        begin
          super
        rescue NoMethodError
          raise NotImplementedError.new("#{self.class}#amount not implemented")
        end
      end
    end
  end
end
