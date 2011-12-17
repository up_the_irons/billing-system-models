class CreditCard < ActiveRecord::Base
  belongs_to :account
  has_many   :charges

  validates_presence_of :number
  validates_presence_of :month
  validates_presence_of :year
  validates_presence_of :first_name
  validates_presence_of :last_name

  validates_numericality_of :number, :if => Proc.new { |c| !c.encrypted? }
  validates_numericality_of :month, :year

  validates_length_of :month, :is => 2
  validates_length_of :year, :is => 4
  validates_length_of :billing_country_iso_3166, :is => 2

  attr_accessor :cvv

  before_save :encrypt!

  named_scope :active, :conditions => { :deleted_at => nil }
  named_scope :inactive, :conditions => "deleted_at IS NOT NULL"

  def encrypted?
    if number.blank?
      return false
    end

    if number =~ /PGP MESSAGE/
      return true
    end

    false
  end

  def valid_number?
    if number !~ /^[0-9]+$/
      return false
    end

    if luhn(number)
      return true
    end

    errors.add(:number, "does not pass Luhn check")
    false
  end

  # http://rosettacode.org/wiki/Luhn_test_of_credit_card_numbers#Ruby
  def luhn(code)
    s1 = s2 = 0
    code.to_s.reverse.chars.each_slice(2) do |odd, even|
      s1 += odd.to_i

      double = even.to_i * 2
      double -= 9 if double >= 10
      s2 += double
    end
    (s1 + s2) % 10 == 0
  end

  # Simple wrapper around private charge!() method that attempts a single
  # charge and returns the gateway response true / false
  def charge(amount)
    gateway_response = charge!(amount)

    if gateway_response
      gateway_response.instance_eval do
        @success
      end
    else
      false
    end
  end

  def charge_with_sales_receipt(amount, line_items = [], opts = {})
    message = opts[:message].to_s
    sold_to = opts[:sold_to].to_s

    amount = amount.to_f

    if amount <= 0
      return false
    end

    if line_items.size == 1 && line_items[0][:amount].nil?
      line_items[0][:amount] = amount
    end

    if !line_items.empty?
      sum = line_items.inject(0) { |sum, x| sum + x[:amount].to_f }

      if sum != amount
        raise SalesReceipt::LineItemSumError.new("Sum of line item amounts do not equal charge amount")
      end
    end

    if opts[:sold_to].nil? && account.respond_to?(:sold_to)
      sold_to = account.sold_to
    end

    if charge(amount)
      ActiveRecord::Base.transaction do
        sr = SalesReceipt.create(:account_id => account.id,
                                 :date => Time.now,
                                 :sold_to => sold_to,
                                 :message => message)

        if sr
          if line_items.empty?
            line_items = [{
              :code => '', :description => '', :amount => amount
            }]
          end

          line_items.each do |line_item|
            sr.line_items.create(
              :code => line_item[:code],
              :description => line_item[:description],
              :amount => line_item[:amount]
            )
          end

          sr
        end
      end
    end
  end

  def destroy
    if !deleted?
      self.update_attribute(:number, '41111')
      self.update_attribute(:deleted_at, Time.now.utc)
    end
  end

  def deleted?
    deleted_at != nil
  end

  private

  def encrypt!
    return true if encrypted?

    if !valid_number?
      return false
    end

    command = "echo #{number} | #{$GPG} --batch --homedir #{$GPG_HOMEDIR} -e --armor --recipient #{$GPG_RECIPIENT} --output -"

    # Instead of using backticks directly, we do it this way in order to be
    # able to stub the method in specs
    output = Kernel.send(:`, command)

    if output =~ /^-----BEGIN PGP MESSAGE-----\n/
      self.number = output
      return true
    end

    false
  end

  # private_key is an ASCII armored version of the secret key
  def decrypt!(private_key, passphrase)
    return true if !encrypted?

    private_key = private_key.to_s
    passphrase = passphrase.to_s

    if private_key.empty? || passphrase.empty?
      return false
    end

    # Is there a way to pass an ASCII armored secret key filename to GPG
    # directly?
    #
    # Couldn't find one, so we must set up temporary GPG staging area
    tmpdir = Dir.mktmpdir

    data = ''
    begin
      gpg_import_private_key!(tmpdir, private_key)
      data = gpg_decrypt!(tmpdir, number, passphrase)

      # Remove tmpdir
      Kernel.system("rm -rf #{tmpdir}")

      if data && !data.empty?
        self.number = data

        return true
      end
    rescue Exception => e
      # Remove tmpdir
      Kernel.system("rm -rf #{tmpdir}")
    end

    false
  end

  def gpg_import_private_key!(tmpdir, private_key)
    private_key_file = tmpdir + '/.privkey.txt'
    File.open(private_key_file, 'w') do |f|
      f.puts(private_key)
    end
    command = "#{$GPG} --batch --homedir #{tmpdir} --import #{private_key_file} 2>/dev/null"
    Kernel.system(command)
  end

  def gpg_decrypt!(tmpdir, data, passphrase)
    if tmpdir.blank? || data.blank? || passphrase.blank?
      return ''
    end

    data_file = tmpdir + '/.data.txt'
    File.open(data_file, 'w') do |f|
      f.puts(data)
    end

    command = "echo '#{passphrase}' | #{$GPG} --batch --homedir #{tmpdir} --passphrase-fd 0 -d #{data_file} 2>/dev/null"

    Kernel.send(:`, command).chomp
  end

  def charge!(amount)
    if amount.nil?
      return nil
    end

    if amount.to_i <= 0
      return nil
    end

    if encrypted?
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
      charge_rec.success = gateway_response.instance_eval { @success }
      charge_rec.save
    end

    return gateway_response
  end
end
