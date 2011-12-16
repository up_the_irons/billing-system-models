module BillingSystemModels
  module CreditCards
    def self.included(base)
      base.module_eval do
        has_many :credit_cards

        include InstanceMethods
      end
    end

    module InstanceMethods
      def credit_card
        credit_cards.active.all(:order => 'updated_at').last
      end
    end
  end
end
