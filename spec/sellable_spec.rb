require File.dirname(__FILE__) + '/spec_helper'

describe "Sellable" do
  before do
    class Foo
      include BillingSystemModels::Sellable
    end
  end

  describe "ClassMethods" do
    describe "create_invoice()" do
      describe "with sellables" do

      end

      describe "without sellables" do
        it "should return false" do
          pending
        end
      end
    end
  end
end
