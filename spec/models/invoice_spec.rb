require File.dirname(__FILE__) + '/../spec_helper'

context "Invoice class" do
  before do
    InvoicesPayment.delete_all
    Payment.delete_all
    InvoicesLineItem.delete_all
    Invoice.delete_all
    Account.delete_all
  end

  context "total()" do
    specify "should be zero if no line items" do
      invoice = Factory(:invoice)
      invoice.line_items.size.should == 0
      invoice.total.should == 0
    end
    specify "should be sum of all line items" do
      invoice = Factory(:invoice, 
                        :line_items => [Factory(:line_item, :amount => 5.00),
                                        Factory(:line_item, :amount => 7.00)])
      invoice.total.should == 12.00
    end
  end

  context "paid()" do
    specify "should be sum of all payments" do
      invoice  = Factory.build(:invoice)
      payments = [Factory.build(:payment, :amount => 5.00),
                  Factory.build(:payment, :amount => 7.00)]

      Factory(:invoices_payment, :invoice => invoice, :payment => payments[0])
      Factory(:invoices_payment, :invoice => invoice, :payment => payments[1])

      invoice.paid.should == 12.00
    end
  end

  context "balance()" do
    context "should be zero if invoice paid in full" do
      specify "with one payment" do
        invoice = Factory.build(:invoice,
                                :line_items => [Factory(:line_item, 
                                                        :amount => 5.00)])
        Factory(:invoices_payment, 
                :invoice => invoice,
                :payment => Factory.build(:payment, :amount => 5.00))

        invoice.balance.should == 0
      end
      specify "with multiple payments" do
        invoice = Factory.build(:invoice,
                                :line_items => [Factory(:line_item, 
                                                        :amount => 5.00),
                                                Factory(:line_item,
                                                        :amount => 7.00)])
        Factory(:invoices_payment, 
                :invoice => invoice,
                :payment => Factory.build(:payment, :amount => 12.00))

        invoice.balance.should == 0
      end
    end
  end

  context "paid in full" do
    before do
      @invoice = Factory.build(:invoice,
                               :line_items => [Factory(:line_item, 
                                                       :amount => 5.00)])
      Factory(:invoices_payment, 
              :invoice => @invoice,
              :payment => Factory.build(:payment, :amount => 5.00))

    end
    specify "should have paid() == total()" do
      @invoice.paid.should == @invoice.total
    end
    specify "should have zero balance" do
      @invoice.balance.should == 0
    end
  end

  context "with no payments" do
    before do
      @invoice = Factory(:invoice)
      @invoice.payments.size.should == 0
    end
    specify "should have balance() == total()" do
      @invoice.balance.should == @invoice.total
    end
    specify "should have zero paid" do
      @invoice.paid.should == 0
    end
  end
end
