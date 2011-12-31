=====================
Billing System Models
=====================

:Author: Garry Dolley
:Date: 06-21-2011

This repository aims to be a collection of ActiveRecord models that can
be included as part of a merchant billing system.

This is a work in progress and not all of the models are particularly
useful yet.  I have also ripped parts of it out from an existing system,
so there are some MySQL specific statements in the migrations.

I am successfully using the Charge, CreditCard, SalesReceipt, and
SalesReceiptsLineItem models in a production system.  The others are not
finished yet.

The models included are:

* Charge
* CreditCard
* Invoice
* InvoicesLineItem
* InvoicesPayment
* Payment
* SalesReceipt
* SalesReceiptsLineItem

Supported processors:

* PayPal (Business or Premier account required)

Requirements
------------

* ActiveRecord
* ActiveMerchant
* ActionMailer
* MySQL
* GnuPG
* FactoryGirl (for running specs)

Installation
------------

::

  cd vendor/plugins/
  git clone git@github.com:up_the_irons/billing-system-models.git

Then run the migrations under ``db/migrate``.

Lastly,

Copy ``lib/gateway.yml.example`` to ``lib/gateway.yml`` and fill in the
fields in that file.

Put your API key file in ``lib/`` and tell ``lib/gateway.yml`` about it
using the "api_key_filename" parameter.  In the example file, the API
key file is named ``my_paypal.pem``

There is one block for the "live" environment, where real credit cards are
charged, and one block for the "test" environment, which mocks everything
through PayPal's Sandbox and no real money is exchanged.

Copy ``lib/gpg.yml.example`` to ``lib/gpg.yml`` and fill in the recipient
field.  This should be the GPG UID of the user whose public key will be used
to encrypt credit card data stored in the database.  The path to your GPG
binary and homedir may also be specified.

Other Processors
----------------

ActiveMerchant supports a large list of credit card processors / gateways.
To use these tools with a gateway besides PayPal, modify gateway.rb to suit
your needs.  It should be relatively straight forward.

See: http://www.activemerchant.org


Notifications
-------------

A ``BillingSystemModels::Mailer`` subclass of ``ActionMailer::Base`` exists to
send emails if/when appropriate.

For these to work, you need to copy the email view templates into your app and
customize them as needed.

For example::

  cd $RAILS_ROOT
  mkdir -p app/views/billing_system_models/mailer
  cp vendor/plugins/billing-system-models/lib/views/* \
     app/views/billing_system_models/mailer

To change the email headers (subject, from, etc...), which you will most
certainly want to do, do the following::

  BillingSystemModels::Mailer.decline_notice_headers = {
    :subject => "Y U NO PAY?",
    :from    => "billing@mycompany.com"
  }

See ``BillingSystemModels::Mailer`` for a full list of modifiable headers.

TODO
----

* Make a gem version
* Remove MySQL specific statements from migrations
* Create a rake task to run migrations for installation

Author
------

Garry C. Dolley

gdolley [at] NOSPAM- arpnetworks.com

AIM: garry97531

IRC: I am up_the_irons on Freenode.

Formatting
----------

This README is formatted in reStructredText [RST]_.  It has the best
correlation between what a document looks like as plain text vs. its
formatted output (HTML, LaTeX, etc...).  What I like best is, markup
doesn't look like markup, even though it is.

.. [RST] http://docutils.sourceforge.net/rst.html

Copyright
---------

Copyright (c) 2011 ARP Networks, Inc.

Released under the MIT license.
