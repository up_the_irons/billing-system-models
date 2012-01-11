require File.dirname(__FILE__) + '/spec_helper'

class Foo
  include BillingSystemModels::Sellable

  def code; 'WIDGET'; end
  def description; 'Part description'; end
  def amount; 10.00; end
end

describe "Sellable" do
  describe "ClassMethods" do
    describe "create_invoice()" do
      describe "with account" do
        before do
          @account = double(:account, :id => 1)
          @date = '01-01-1970'
          @opts = { :date => @date }
        end

        describe "with sellables" do
          before do
            @sellables = [Foo.new]
          end

          it "should create invoice with line items and return true" do
            @invoice = double(:invoice,
                              :new_record? => false)
            Invoice.should_receive(:create).with(
              :account_id => @account.id,
              :date       => @date,
              :terms      => '',
              :message    => ''
            ).and_return(@invoice)

            @line_items = double(:line_items)
            @invoice.should_receive(:line_items).and_return(@line_items)
            @line_items.should_receive(:create).with(
              :date => @date,
              :code => @sellables[0].code,
              :description => @sellables[0].description,
              :amount => @sellables[0].amount
            ).and_return(true)

            Foo.create_invoice(@account, @sellables, @opts).should == true
          end

          context "when invoice cannot be created" do
            before do
              # Bad account ID
              @account = double(:account, :id => nil)
            end

            it "should raise exception" do
              lambda {
                Foo.create_invoice(@account, @sellables, @opts)
              }.should raise_error(StandardError)
            end
          end

          context "when an invoice line item cannot be created" do
            before do
              @invoice = double(:invoice,
                                :new_record? => false)
              Invoice.should_receive(:create).and_return(@invoice)

              @invoice.should_receive(:line_items).and_return(@line_items)
              @line_items.should_receive(:create).and_return(false)
            end

            it "should raise exception" do
              lambda {
                Foo.create_invoice(@account, @sellables, @opts)
              }.should raise_error(StandardError)
            end
          end
        end

        describe "without sellables" do
          before do
            @sellables = []
          end

          it "should return false" do
            Foo.create_invoice(@account, @sellables).should == false
          end
        end
      end

      context "without account" do
        before do
          @account = nil
        end

        it "should return false" do
          Foo.create_invoice(@account, @sellables).should == false
        end
      end
    end
  end
end
