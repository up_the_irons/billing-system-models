require File.dirname(__FILE__) + '/../spec_helper'

context "CreditCard class with fixtures loaded" do

  before :each do
    @number = "encrypted data"
    @month  = "01"
    @year   = "2018"
    @cvv    = 999
    @first_name = "John"
    @last_name  = "Doe"

    Account.delete_all

    @cc = Factory.create(:credit_card,
      :number     => @number,
      :month      => @month,
      :year       => @year,
      :first_name => @first_name,
      :last_name  => @last_name
    )
  end

  def credit_card_hash
    {
      :number => @number,
      :month => @month,
      :year => @year,
      :verification_value => @cvv,
      :first_name => @first_name,
      :last_name => @last_name
    }
  end

  context "charge()" do
    specify "should create Charge record" do
      @cc.charges.should_receive(:create).with(
        :date => Date.today.strftime("%Y-%m-%d"),
        :amount => 10.00).and_return(Charge.new)

      $GATEWAY.stub!(:purchase).and_return('')

      @cc.instance_eval do
        charge(10.00)
      end
    end

    specify "should add gateway response to Charge record" do
      gateway_response = 'gateway response'

      ActiveMerchant::Billing::CreditCard.stub!(:new).and_return(nil)

      @charge_rec = Factory.create(:charge)
      @cc.charges.stub!(:create).and_return(@charge_rec)

      $GATEWAY.should_receive(:purchase).with(
        1000,
        nil,
        :ip => '127.0.0.1',
        :billing_address => nil).and_return(gateway_response)

      @cc.instance_eval do
        charge(10.00)
      end

      @charge_rec.gateway_response.should == gateway_response
    end

    specify "should build ActiveMerchant credit card object with card details" do
      ActiveMerchant::Billing::CreditCard.should_receive(:new).with(
        credit_card_hash
      )

      $GATEWAY.stub!(:purchase).and_return('')

      @cc.instance_eval do
        charge(10.00)
      end
    end

    specify "should call gateway to charge credit card" do
      credit_card = ActiveMerchant::Billing::CreditCard.new(
        credit_card_hash
      )

      ActiveMerchant::Billing::CreditCard.stub!(:new).and_return(credit_card)

      $GATEWAY.should_receive(:purchase).with(
        1000,
        credit_card,
        :ip => '127.0.0.1',
        :billing_address => nil)

      @cc.instance_eval do
        charge(10.00)
      end
    end

    specify "should call gateway with correct billing address" do
      pending
    end

    specify "should not call gateway to charge credit card if Charge record not saved" do
      charge_rec = Charge.new
      @cc.charges.stub!(:create).and_return(Charge.new)

      charge_rec.new_record?.should == true
      $GATEWAY.should_not_receive(:purchase)

      @cc.instance_eval do
        charge(10.00)
      end
    end

    context "on success" do
      specify "should return gateway response hash" do
        gateway_response = 'gateway response'

        ActiveMerchant::Billing::CreditCard.stub!(:new).and_return(nil)

        $GATEWAY.should_receive(:purchase).with(
          1000,
          nil,
          :ip => '127.0.0.1',
          :billing_address => nil).and_return(gateway_response)

        @cc.instance_eval do
          charge(10.00)
        end.should == gateway_response
      end
    end

    context "on failure" do
      before(:all) do
        $GATEWAY.stub!(:purchase).and_return('')
      end

      specify "should return nil" do
        @cc.charges.stub!(:create).and_return(Factory.build(:charge))

        @cc.instance_eval do
          charge(10.00)
        end.should == nil
      end

      specify "should return nil when amount is 0" do
        @cc.instance_eval { charge(0) }.should == nil
      end

      specify "should return nil when amount is less than 0" do
        @cc.instance_eval { charge(-1) }.should == nil
      end

      specify "should return nil when amount is blank" do
        @cc.instance_eval { charge("") }.should == nil
      end

      specify "should return nil when amount is nil" do
        @cc.instance_eval { charge(nil) }.should == nil
      end
    end
  end

  context "charge_and_record_payment() <-- ???" do
  end
end
