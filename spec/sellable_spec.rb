require File.dirname(__FILE__) + '/spec_helper'

class Foo
  include BillingSystemModels::Sellable
end

describe "Sellable" do
  describe "ClassMethods" do
    describe "create_invoice()" do
      describe "with sellables" do

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
