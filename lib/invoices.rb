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

      def invoices_paid
        invoices.paid
      end

      def invoices_unpaid
        invoices.unpaid
      end

      def invoices_outstanding_balance
        if invoices_unpaid.nil?
          return 0
        end

        invoices_unpaid.inject(0) do |sum, invoice|
          invoice.balance + sum
        end
      end
    end
  end
end
