require File.dirname(__FILE__) + '/../spec_helper'

context "CreditCard class with fixtures loaded" do

  before :each do
    @number = "PGP MESSAGE"
    @month  = "01"
    @year   = "2018"
    @cvv    = "999"
    @first_name = "John"
    @last_name  = "Doe"

    SalesReceiptsLineItem.delete_all
    SalesReceipt.delete_all
    InvoicesPayment.delete_all
    Payment.delete_all
    InvoicesLineItem.delete_all
    Invoice.delete_all
    Charge.delete_all
    CreditCard.delete_all
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
      :first_name => @first_name,
      :last_name => @last_name
    }
  end

  context "valid_number?()" do
    context "when credit card number passes Luhn test" do
      before do
        # This passes Luhn test
        @cc = CreditCard.new(:number => '1234567812345670')
      end

      specify "should return true" do
        @cc.valid_number?.should == true
      end
    end

    context "when credit card number does not pass Luhn test" do
      before do
        # This does not pass Luhn test
        @cc = CreditCard.new(:number => '1234567812345678')
      end

      specify "should return false" do
        @cc.valid_number?.should == false
      end
    end

    context "when credit card number contains non-numeric characters" do
      before do
        @cc = CreditCard.new(:number => '4111foo')
      end

      specify "should return false" do
        @cc.valid_number?.should == false
      end
    end
  end

  context "encrypted?()" do
    context "with encrypted credit card number" do
      before do
        @cc = CreditCard.new(credit_card_hash.merge(:number => <<-ENCRYPTED
-----BEGIN PGP MESSAGE-----
Version: GnuPG v1.4.10 (GNU/Linux)

hQIMA8MXmy8BLfGpARAAgiRtx2j7k4KAGUdEPvmXPTH5DJvWnNynqIIg1JACDWK+
xNFa00DP0MCBzv5rV0qZFogL473XYpPS0Q9sfZJ3lFTibzWLwm5CTxLzrNsMM9Ul
ZKMixsFoSLYioTgukZMAUnBZHwUjb2vOPRvVClQmOKjJFzCDHTPhYF/WbFSgDtzM
G/0nB/qP4gd68HM/aySs3zqj1C6tXNZMCC9ZUY1+eiBQeS/lOuCrgcLwj6UZVU5J
87jcJW/6ExPajfm46DdA1drnOBa00pQ8FiXxezNjdCadqB2AvxtuclFRxR5X2cJu
zNGI5295aE4fDyuhQ05FJGHbzLhtg8qh9X3FKZ86+yh4OabAqoRwMpthA+tX9BYB
Fd/kw8qtjXnFcN4VxpR+CYvWhNoanxe4zNrZUArCodrFVhCdfmdr3kmsb70R1d0n
BtkkiW+6eCKpJVjfaddhetSWu/dV3o9l7X4U7fI9QfQK5DUa4MdGpOMJs1k/EOJI
F13tCIXxk7+gzCveMXrwhVkXDk/12srJz7wHlvvOixt/jm022TiiEV81UJxNYsnC
+HOC0PrjURbShGH133b8NXbOdAdUmR5yxoZbPeD+j9P5Jg7UkBYPG/0AMH/QhF30
DFpDfySJhO/f6a5k+ct+inho5QX1VU2MB0U0/nwZGPmBqT0FSpOmbBvaiyvMG9DS
PwGGXwJOFdbXQl+BuHsfgvw8VmJOoz/57Rt3OVekCiGBE6/EisoM4fiJWsZ8194X
xXLTCQ4aVp2k8kH6CgqYDw==
=DjNl
-----END PGP MESSAGE-----
ENCRYPTED
                                                   ))
      end

      specify "should return true" do
        @cc.encrypted?.should == true
      end
    end

    context "with clear text credit card number" do
      before do
        @cc = CreditCard.new(credit_card_hash.merge(:number =>
                                                    '4111111111111111'))

      end

      specify "should return false" do
        @cc.encrypted?.should == false
      end
    end

    context "with empty credit card number" do
      before do

        @cc = CreditCard.new(credit_card_hash.merge(:number => ''))

      end

      specify "should return false" do
        @cc.encrypted?.should == false
      end
    end
  end

  context "unlock!()" do
    before do
      @private_key = 'key'
      @passphrase  = 'pass'
    end

    def do_unlock!
      CreditCard.unlock!(@private_key, @passphrase)
    end

    specify "should return true" do
      do_unlock!.should == true
    end

    specify "should assign private_key to class variable" do
      CreditCard.should_receive(:private_key=).with(@private_key)
      do_unlock!
    end

    specify "should assign passphrase to class variable" do
      CreditCard.should_receive(:passphrase=).with(@passphrase)
      do_unlock!
    end
  end

  context "encrypt!()" do
    before do
      $GPG = 'gpg'
      @cc = CreditCard.new(credit_card_hash)
    end

    def do_encrypt!
      @cc.instance_eval do
        encrypt!
      end
    end

    context "with encrypted credit card number" do
      before do
        @cc_number = "I am encrypted"
        @cc.should_receive(:encrypted?).and_return(true)
        @cc.number = @cc_number
      end

      specify "should not alter credit card number" do
        @cc.number.should == @cc_number
        do_encrypt!
        @cc.number.should == @cc_number
      end

      specify "should return true" do
        do_encrypt!.should == true
      end
    end

    context "with invalid credit card number" do
      before do
        @cc.stub!(:encrypted?).and_return(false)
        @cc.should_receive(:valid_number?).and_return(false)
      end

      specify "should return false" do
        do_encrypt!.should == false
      end
    end

    context "with clear text credit card number" do
      before do
        @cc.should_receive(:encrypted?).and_return(false)
        @cc.should_receive(:valid_number?).and_return(true)
        Kernel.stub!(:`).and_return(true)
      end

      specify "should call gpg" do
         $GPG_RECIPIENT = 'me@example.com'
         Kernel.should_receive(:`).with("echo #{@number} | gpg --batch --homedir #{$GPG_HOMEDIR} -e --armor --recipient #{$GPG_RECIPIENT} --output -")
         do_encrypt!
      end

      context "upon successful gpg" do
        before do
          @encrypted_number = "-----BEGIN PGP MESSAGE-----\n"
          Kernel.stub!(:`).and_return(@encrypted_number)
        end

        specify "should return true" do
          do_encrypt!.should == true
        end

        specify "number should be encrypted" do
          do_encrypt!
          @cc.number.should == @encrypted_number
        end
      end

      context "upon unsuccessful gpg" do
        before do
          Kernel.stub!(:`).and_return('')
        end

        specify "should return false" do
          do_encrypt!.should == false
        end
      end
    end
  end

  context "decrypt!()" do
    before do
      $GPG = 'gpg'

      @cc = CreditCard.new(credit_card_hash)

      @private_key = 'foobar'
      @passphrase  = 'nosekritz'
    end

    def do_decrypt!(private_key, passphrase)
      @cc.instance_eval do
        decrypt!(private_key, passphrase)
      end
    end

    before do
      @tmpdir = '/tmp/foo'
      Dir.stub!(:mktmpdir).and_return(@tmpdir)
    end

    context "with encrypted credit card number" do
      before do
        @cc.should_receive(:encrypted?).and_return(true)
        @cc.stub!(:gpg_import_private_key!)
        @cc.stub!(:gpg_decrypt!)
      end

      specify "should create and remove temporary directory" do
        Dir.should_receive(:mktmpdir).and_return(@tmpdir)
        Kernel.should_receive(:system).with("rm -rf #{@tmpdir}")
        do_decrypt!(@private_key, @passphrase)
      end

      context "with private key and passphrase" do
        before do
          @private_key = 'foobar'
          @passphrase  = 'nosekritz'
        end

        specify "should import private key" do
          @cc.should_receive(:gpg_import_private_key!).with(@tmpdir,
                                                            @private_key)
          do_decrypt!(@private_key, @passphrase)
        end

        specify "should decrypt data and assign to number" do
          @clear = 'clear text'
          @cc.stub!(:gpg_import_private_key)
          @cc.should_receive(:gpg_decrypt!).with(@tmpdir, @cc.number, @passphrase).\
            and_return(@clear)

          do_decrypt!(@private_key, @passphrase)

          @cc.number.should == @clear
        end

        context "when decryption returns empty string" do
          specify "should not assign to number" do
            @before = @cc.number
            @cc.stub!(:gpg_import_private_key)
            @cc.should_receive(:gpg_decrypt!).with(@tmpdir, @cc.number, @passphrase).\
              and_return('')

            do_decrypt!(@private_key, @passphrase)

            @cc.number.should == @before
          end
        end

        context "when exception raised" do
          before do
            @cc.should_receive(:gpg_import_private_key!).and_raise(Exception)
          end

          specify "should remove temporary directory" do
            Kernel.should_receive(:system).with("rm -rf #{@tmpdir}")
            do_decrypt!(@private_key, @passphrase)
          end

          specify "should return false" do
            do_decrypt!(@private_key, @passphrase).should == false
          end
        end
      end

      context "without private key" do
        before do
          @private_key = ''
        end

        specify "should defer to CreditCard.private_key" do
          CreditCard.should_receive(:private_key)
          do_decrypt!(@private_key, @passphrase)
        end

        specify "should return false" do
          do_decrypt!(@private_key, @passphrase).should == false
        end
      end

      context "without passphrase" do
        before do
          @passphrase = ''
        end

        specify "should defer to CreditCard.passphrase" do
          CreditCard.should_receive(:passphrase)
          do_decrypt!(@private_key, @passphrase)
        end

        specify "should return false" do
          do_decrypt!(@private_key, @passphrase).should == false
        end
      end
    end

    context "with clear text credit card number" do
      before do
        @cc.should_receive(:encrypted?).and_return(false)
        @cc.number = @number
      end

      specify "should not alter credit card number" do
        @cc.number.should == @number
        do_decrypt!(@private_key, @passphrase)
        @cc.number.should == @number
      end

      specify "should return true" do
        do_decrypt!(@private_key, @passphrase).should == true
      end
    end
  end

  context "gpg_import_private_key!()" do
    before do
      @tmpdir = '/tmp/foo'
      @private_key = 'foobar'
    end

    def do_gpg_import_private_key!
      tmpdir = @tmpdir
      private_key = @private_key

      @cc.instance_eval do
        gpg_import_private_key!(tmpdir, private_key)
      end
    end

    specify "should import private key" do
      private_key_file = @tmpdir + "/.privkey.txt"
      File.should_receive(:open).with(private_key_file, 'w')
      command = "gpg --batch --homedir #{@tmpdir} --import #{private_key_file} 2>/dev/null"
      Kernel.should_receive(:system).with(command)
      do_gpg_import_private_key!
    end
  end

  context "gpg_decrypt!()" do
    def do_gpg_decrypt!
      tmpdir = @tmpdir
      data = @data
      passphrase = @passphrase

      @cc.instance_eval do
        gpg_decrypt!(tmpdir, data, passphrase)
      end
    end

    context "with temporary directory, data, and passphrase" do
      before do
        @tmpdir = '/tmp/foo'
        @data = 'PGP MESSAGE'
        @passphrase = 'foobar'
      end

      specify "should decrypt data" do
        data_file = @tmpdir + '/.data.txt'
        File.should_receive(:open).with(data_file, 'w')
        command = "echo '#{@passphrase}' | gpg --batch --homedir #{@tmpdir} --passphrase-fd 0 -d #{data_file} 2>/dev/null"
        Kernel.should_receive(:`).with(command).and_return("")
        do_gpg_decrypt!
      end
    end

    context "without temporary directory, data, or passphrase" do
      specify "should return empty string" do
        @tmpdir = ''
        do_gpg_decrypt!.should == ''
        @tmpdir = '/tmp/foo'

        @data = ''
        do_gpg_decrypt!.should == ''
        @data = 'PGP MESSAGE'

        @passphrase = ''
        do_gpg_decrypt!.should == ''
        @passphrase = 'foobar'
      end
    end
  end

  context "charge" do
    before do
      @amount = 1.00

      class MockGatewayResponse
        attr_accessor :success
      end

      @mock_gateway_response = MockGatewayResponse.new
      @mock_gateway_response.success = true

      @charge_rec = double(:charge_rec,
                           :gateway_response => @mock_gateway_response)
    end

    specify "should call charge!()" do

      @cc.should_receive(:charge!).with(@amount).\
        and_return(@charge_rec)
      @cc.charge(@amount)
    end

    context "when successful charge" do
      before do
        @cc.stub!(:charge!).and_return(@charge_rec)
      end

      specify "should return true" do
        @cc.charge(@amount).should == true
      end
    end

    context "when unsuccessful charge" do
      before do
        @mock_gateway_response = MockGatewayResponse.new
        @mock_gateway_response.success = false
        @charge_rec = double(:charge_rec,
                             :gateway_response => @mock_gateway_response)

        @cc.stub!(:charge!).and_return(@charge_rec)
      end

      specify "should return false" do
        @cc.charge(@amount).should == false
      end
    end
  end

  context "charge_with_sales_receipt" do
    context "with valid amount" do
      before do
        @amount = 1.00
      end

      specify "should call charge with amount" do
        @cc.should_receive(:charge).with(@amount)
        @cc.charge_with_sales_receipt(@amount)
      end

      context "with successful charge" do
        before do
          @cc.stub!(:charge).and_return(true)
        end

        specify "should create receipt" do
          Time.stub!(:now).and_return('today')

          SalesReceipt.should_receive(:create).with(
            :account_id => @cc.account.id,
            :date => 'today',
            :sold_to => Account.new.sold_to,
            :message => '')

          @cc.charge_with_sales_receipt(@amount)
        end

        context "with line items" do
          before do
            @line_items = [
              { :code => 'FOO',
                :description => 'foo',
                :amount => 2.00 },
              { :code => 'BAR',
                :description => 'bar',
                :amount => 3.00 }
            ]
          end

          context "with correct line item amounts" do
            before do
              @amount = 5.00
            end

            specify "should create new line items" do
              @mock_sales_receipt = double(:sales_receipt)
              @mock_line_items = mock(:line_items,
                                      :create => true)
              @mock_sales_receipt.should_receive(:line_items).twice.\
                and_return(@mock_line_items)
              SalesReceipt.stub!(:create).and_return(@mock_sales_receipt)
              @cc.charge_with_sales_receipt(@amount, @line_items)
            end
          end

          context "with incorrect line item amounts" do
            before do
              @amount = 7.00
            end

            specify "should raise error" do
              lambda do
                @cc.charge_with_sales_receipt(@amount, @line_items)
              end.should raise_error(SalesReceipt::LineItemSumError)
            end
          end

          context "with exactly one line item" do
            context "without line item amount" do
              before do
                @amount = 5.00

                @line_items = [
                  { :code => 'FOO',
                    :description => 'foo' }
                ]
              end

              specify "should use total amount for line item amount" do
                @mock_sales_receipt = double(:sales_receipt)
                @mock_line_items = mock(:line_items,
                                        :create => true)
                @mock_line_items.should_receive(:create).with(
                  @line_items[0].merge(:amount => @amount)
                ).and_return(true)
                @mock_sales_receipt.should_receive(:line_items).once.\
                  and_return(@mock_line_items)
                SalesReceipt.stub!(:create).and_return(@mock_sales_receipt)
                @cc.charge_with_sales_receipt(@amount, @line_items)
              end
            end
          end
        end

        context "without line items" do
          before do
            @line_items = []
          end

          specify "should create minimal line item with only amount" do
            @mock_sales_receipt = double(:sales_receipt)
            @mock_line_items = mock(:line_items)
            @mock_line_items.should_receive(:create).with(
              :code => '', :description => '', :amount => @amount)
            @mock_sales_receipt.should_receive(:line_items).once.\
              and_return(@mock_line_items)
            SalesReceipt.stub!(:create).and_return(@mock_sales_receipt)
            @cc.charge_with_sales_receipt(@amount, @line_items)
          end

          context "without sold_to option" do
            context "with Account that responds to sold_to" do
              before do
                @sold_to = Account.new.sold_to
              end

              specify "should use Account#sold_to as sold_to" do
                Time.stub!(:now).and_return('today')

                SalesReceipt.should_receive(:create).with(
                  :account_id => @cc.account.id,
                  :date => 'today',
                  :sold_to => @sold_to,
                  :message => '')

                @cc.charge_with_sales_receipt(@amount)
              end
            end
          end
        end
      end

      context "when unsuccessful charge" do
        before do
          @cc.stub!(:charge).and_return(false)
        end

        specify "should not create sales receipt" do
          SalesReceipt.should_not_receive(:create)
          @cc.charge_with_sales_receipt(@amount)
        end

        specify "should return nil" do
          @cc.charge_with_sales_receipt(@amount).should == nil
        end

        context "when email_decline_notice option is true" do
          before do
            @opts = {
              :email_decline_notice => true
            }
          end

          specify "should deliver decline_notice through Mailer" do
            account = @cc.account

            BillingSystemModels::Mailer.\
              should_receive(:deliver_decline_notice).\
              with(account)
            @cc.charge_with_sales_receipt(@amount, [], @opts)
          end

          specify "should return nil" do
            account = @cc.account

            BillingSystemModels::Mailer.\
              should_receive(:deliver_decline_notice).\
              with(account).and_return(:tmail_obj)
            @cc.charge_with_sales_receipt(@amount, [], @opts).should == nil
          end
        end
      end
    end

    context "with invalid amount" do
      context "is nil" do
        before do
          @amount = nil
        end

        specify "should return false" do
          @cc.charge_with_sales_receipt(@amount).should == false
        end
      end

      context "is 0" do
        before do
          @amount = 0
        end

        specify "should return false" do
          @cc.charge_with_sales_receipt(@amount).should == false
        end
      end

      context "is < 0" do
        before do
          @amount = -1
        end

        specify "should return false" do
          @cc.charge_with_sales_receipt(@amount).should == false
        end
      end
    end
  end

  context "charge!()" do
    before do
      @cc.stub!(:encrypted?).and_return(false)
    end

    specify "should create Charge record" do
      @cc.charges.should_receive(:create).with(
        :date => Date.today.strftime("%Y-%m-%d"),
        :amount => 10.00).and_return(Charge.new)

      $GATEWAY.stub!(:purchase).and_return('')

      @cc.instance_eval do
        charge!(10.00)
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
        charge!(10.00)
      end

      @charge_rec.gateway_response.should == gateway_response
    end

    specify "should build ActiveMerchant credit card object with card details" do
      ActiveMerchant::Billing::CreditCard.should_receive(:new).with(
        credit_card_hash.merge!(:verification_value => @cvv)
      )

      $GATEWAY.stub!(:purchase).and_return('')

      @cc.instance_eval do
        charge!(10.00)
      end
    end

    specify "should call gateway to charge credit card" do
      credit_card = ActiveMerchant::Billing::CreditCard.new(
        credit_card_hash.merge!(:verification_value => @cvv)
      )

      ActiveMerchant::Billing::CreditCard.stub!(:new).and_return(credit_card)

      $GATEWAY.should_receive(:purchase).with(
        1000,
        credit_card,
        :ip => '127.0.0.1',
        :billing_address => nil)

      @cc.instance_eval do
        charge!(10.00)
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
        charge!(10.00)
      end
    end

    context "on success" do
      specify "should return charge record" do
        gateway_response = 'gateway response'

        charge_rec = double(:charge_rec,
                            :new_record? => false,
                            :gateway_response= => gateway_response,
                            :success= => true,
                            :save => true)

        @cc.charges.stub!(:create).and_return(charge_rec)

        ActiveMerchant::Billing::CreditCard.stub!(:new).and_return(nil)

        $GATEWAY.should_receive(:purchase).with(
          1000,
          nil,
          :ip => '127.0.0.1',
          :billing_address => nil).and_return(gateway_response)

        @cc.instance_eval do
          charge!(10.00)
        end.should == charge_rec
      end
    end

    context "on failure" do
      before(:all) do
        $GATEWAY.stub!(:purchase).and_return('')
      end

      specify "should return nil" do
        @cc.charges.stub!(:create).and_return(Factory.build(:charge))

        @cc.instance_eval do
          charge!(10.00)
        end.should == nil
      end

      specify "should return nil when amount is 0" do
        @cc.instance_eval { charge!(0) }.should == nil
      end

      specify "should return nil when amount is less than 0" do
        @cc.instance_eval { charge!(-1) }.should == nil
      end

      specify "should return nil when amount is blank" do
        @cc.instance_eval { charge!("") }.should == nil
      end

      specify "should return nil when amount is nil" do
        @cc.instance_eval { charge!(nil) }.should == nil
      end

      specify "should return nil when number is encrypted" do
        @cc.stub!(:encrypted?).and_return(true)
        @cc.instance_eval { charge!(5) }.should == nil
      end
    end
  end
end
