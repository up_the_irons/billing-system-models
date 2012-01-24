module BillingSystemModels
  module CreditCards
    def self.included(base)
      base.module_eval do
        has_many :credit_cards
        has_many :sales_receipts

        include InstanceMethods
      end
    end

    module InstanceMethods
      def credit_card
        credit_cards.active.all(:order => 'updated_at').last
      end

      # Your model should have an 'email' field to support sending email
      # notification of certain events (e.g. credit card declines, sales
      # receipt emails, etc...)
      #
      # If it does not, emails will be disabled
      def email
        begin
          super
        rescue NoMethodError
          nil
        end
      end
    end
  end
end
