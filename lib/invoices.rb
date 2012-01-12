module BillingSystemModels
  module Invoices
    def self.included(base)
      base.module_eval do
        has_many :invoices
      end
    end
  end
end
