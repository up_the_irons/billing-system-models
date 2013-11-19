require File.dirname(__FILE__) + '/spec_helper'

class Foo
  def self.has_many(foo)
    # Stub
  end

  include BillingSystemModels::Invoices
end

describe 'Invoices' do
  describe 'InstanceMethods' do
    before do
      @my_class = Foo.new
    end

    describe 'invoices_paid()' do
      it 'should call invoices.paid' do
        @invoices = double(:invoices)
        @invoices.should_receive(:paid)
        @my_class.should_receive(:invoices).and_return(@invoices)
        @my_class.invoices_paid
      end
    end

    describe 'invoices_unpaid()' do
      it 'should call invoices.unpaid' do
        @invoices = double(:invoices)
        @invoices.should_receive(:unpaid)
        @my_class.should_receive(:invoices).and_return(@invoices)
        @my_class.invoices_unpaid
      end
    end

    describe 'invoices_outstanding_balance()' do
      describe 'when no invoices' do
        before do
          @my_class.stub!(:invoices_unpaid).and_return(nil)
        end

        it 'should return zero' do
          @my_class.invoices_outstanding_balance.should == 0
        end
      end

      describe 'when all invoices are paid' do
        before do
          @my_class.stub!(:invoices_unpaid).and_return([])
        end

        it 'should return zero' do
          @my_class.invoices_outstanding_balance.should == 0
        end
      end

      describe 'when some invoices are unpaid' do
        before do
          @unpaid_invoices = [
            double(:invoice, :balance => 20.00),
            double(:invoice, :balance => 1.00)
          ]
          @my_class.stub!(:invoices_unpaid).and_return(@unpaid_invoices)
        end

        it 'should return total unpaid balance' do
          @my_class.invoices_outstanding_balance.should == 21.00
        end
      end
    end
  end
end
