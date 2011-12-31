module BillingSystemModels
  class Mailer < ActionMailer::Base
    cattr_accessor :decline_notice_headers
    cattr_accessor :sales_receipt_headers

    @@decline_notice_headers = {
      :subject => "Your credit card has declined",
      :from    => "noreply@example.com"
    }

    @@sales_receipt_headers = {
      :subject => "Sales receipt",
      :from    => "noreply@example.com"
    }

    def decline_notice(account)
      if account.email
        @subject = self.class.decline_notice_headers[:subject]
        @from    = self.class.decline_notice_headers[:from]
        @cc      = self.class.decline_notice_headers[:cc]

        @recipients = [account.email]

        @body = {
          :account => account
        }
      end
    end

    # There is no view template for this one yet
    def sales_receipt(account)
      if account.email
        @subject = self.class.sales_receipt_headers[:subject]
        @from    = self.class.sales_receipt_headers[:from]
        @cc      = self.class.sales_receipt_headers[:cc]

        @recipients = [account.email]

        @body = {
          :account => account
        }
      end
    end
  end
end
