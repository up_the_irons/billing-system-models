# Dependencies
# ------------

require 'rubygems'

begin
  require 'active_record'
rescue LoadError
  require 'activerecord'
end

require 'active_merchant'
require 'tmpdir'

$:.unshift File.join(File.dirname(__FILE__), "lib")

# Gateway configuration
# ---------------------

require 'gateway'

# GPG configuration
# -----------------

require 'gpg'

# Our models
# ----------

require 'credit_cards' # Mixin module

$:.unshift File.join(File.dirname(__FILE__), "lib", "models")

require 'charge'
require 'credit_card'
require 'invoice'
require 'payment'
require 'sales_receipt'

require 'sales_receipts_line_item'
require 'invoices_line_item'
require 'invoices_payment'
