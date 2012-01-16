module BillingSystemModels
  module Invoices
    def self.included(base)
      base.module_eval do
        has_many :invoices
        has_many :payments
      end
    end
  end
end
