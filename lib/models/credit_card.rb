class CreditCard < ActiveRecord::Base
  belongs_to :account
  has_many   :charges

  validates_presence_of :number
  validates_presence_of :month
  validates_presence_of :year
  validates_presence_of :first_name
  validates_presence_of :last_name

  attr_accessor :cvv

  def encrypted?
    if number.blank?
      return false
    end

    if number =~ /PGP MESSAGE/
      return true
    end

    false
  end

  private

  def encrypt!
    if encrypted? || !is_valid_number?
      return false
    end

    command = "echo #{number} | gpg --batch -e --armor --recipient #{$GPG_RECIPIENT} --output -"

    # Instead of using backticks directly, we do it this way in order to be
    # able to stub the method in specs
    output = Kernel.send(:`, command)

    if output =~ /^-----BEGIN PGP MESSAGE-----\n/
      return true
    end

    false
  end

  def charge(amount)
    if amount.nil?
      return nil
    end

    if amount.to_i <= 0
      return nil
    end

    credit_card = ActiveMerchant::Billing::CreditCard.new(
      :number => number,
      :month  => month,
      :year   => year,
      :first_name => first_name,
      :last_name  => last_name,
      :verification_value => cvv
    )

    charge_rec = charges.create(:date   => Date.today.strftime("%Y-%m-%d"),
                                :amount => amount)

    # Convert dollars to cents
    amount = (BigDecimal(amount.to_s) * 100).to_i

    gateway_response = nil
    if charge_rec.new_record? == false
      gateway_response = $GATEWAY.purchase(amount,
                                           credit_card,
                                           :ip => '127.0.0.1',
                                           :billing_address => nil)

      charge_rec.gateway_response = gateway_response
      charge_rec.save
    end

    return gateway_response
  end
end
