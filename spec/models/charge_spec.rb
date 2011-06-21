require File.dirname(__FILE__) + '/../spec_helper'

context "Charge class with fixtures loaded" do
  specify "should count two Charges" do
    Charge.delete_all
    Factory.create(:charge)
    Factory.create(:charge)
    Charge.count.should == 2
  end
end
