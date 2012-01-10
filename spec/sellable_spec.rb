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
      describe "with sellables" do
        it "should create invoice with line items" do
          pending
        end
      end

      describe "without sellables" do
        before do
          @sellables = []
        end

        it "should return false" do
          Foo.create_invoice(@sellables).should == false
        end
      end
    end
  end
end
