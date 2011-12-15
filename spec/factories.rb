Factory.define :account do |a|
end

Factory.define :invoice do |i|
  i.association :account
end

Factory.define :line_item, :class => InvoicesLineItem do |li|
  li.association :invoice
end

Factory.define :payment do |p|
  p.association :account
end

Factory.define :invoices_payment do |ip|
  ip.association :invoice
  ip.association :payment
end

Factory.define :credit_card do |cc|
  cc.association :account
  cc.number 'PGP MESSAGE'
  cc.month "01"
  cc.year "2018"
  cc.cvv "999"
  cc.first_name "John"
  cc.last_name "Doe"
  cc.billing_country_iso_3166 "US"
end

Factory.define :charge do |c|
  c.association :credit_card
  c.amount 5.00
end
