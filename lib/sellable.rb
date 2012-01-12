module BillingSystemModels
  module Sellable
    def self.included(base)
      base.module_eval do
        include InstanceMethods
        extend ClassMethods
      end
    end

    module ClassMethods
      def create_invoice(account, sellables, opts = {})
        date = opts[:date] || Time.now
        terms = opts[:terms].to_s
        message = opts[:message].to_s

        sellables = [sellables].compact.flatten

        if account.nil?
          return false
        end

        if sellables.empty?
          return false
        end

        ActiveRecord::Base.transaction do
          invoice = Invoice.create(:account_id => account.id,
                                   :date => date,
                                   :terms => terms,
                                   :message => message)

          if invoice && !invoice.new_record?
            sellables.each do |sellable|
              code = sellable.code
              description = sellable.description
              amount = sellable.amount

              if !invoice.line_items.create(:date => date,
                                            :code => code,
                                            :description => description,
                                            :amount => amount)
                raise "Failed to create an invoice line item"
              end
            end

            true
          else
            raise "Invoice failed to be created"
          end
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
