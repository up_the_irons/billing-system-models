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
        date = opts[:date]
        terms = opts[:terms].to_s
        message = opts[:message].to_s

        sellables = [sellables].flatten

        if sellables.empty?
          return false
        end
      end
    end

    module InstanceMethods
      def code
        begin
          super
        rescue NoMethodError
          raise NotImplementedError.new("#{self.class}#code not implemented")
        end
      end

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
