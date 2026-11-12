-- Independently defined representative schema for synthetic integration tests.

-- Contains no customer records, deployment secrets, or data from the WHMCS dump.

CREATE TABLE `tblaccounts` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `currency` BIGINT NOT NULL DEFAULT 0,
  `gateway` TEXT NOT NULL DEFAULT (''),
  `date` DATETIME DEFAULT NULL,
  `description` TEXT NOT NULL DEFAULT (''),
  `amountin` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `fees` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `amountout` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `rate` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `transid` TEXT NOT NULL DEFAULT (''),
  `invoiceid` BIGINT NOT NULL DEFAULT 0,
  `refundid` BIGINT NOT NULL DEFAULT 0,
  `billingnoteid` BIGINT NOT NULL DEFAULT 0,
  `type` TEXT NOT NULL DEFAULT (''),
  `relid` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblactivitylog` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `date` DATETIME DEFAULT NULL,
  `description` TEXT NOT NULL DEFAULT (''),
  `user` TEXT NOT NULL DEFAULT (''),
  `userid` BIGINT NOT NULL DEFAULT 0,
  `user_id` BIGINT NOT NULL DEFAULT 0,
  `admin_id` BIGINT NOT NULL DEFAULT 0,
  `ipaddr` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbladdons` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `packages` TEXT NOT NULL DEFAULT (''),
  `name` TEXT NOT NULL DEFAULT (''),
  `description` TEXT NOT NULL DEFAULT (''),
  `billingcycle` TEXT NOT NULL DEFAULT (''),
  `allowqty` BIGINT NOT NULL DEFAULT 0,
  `tax` BIGINT NOT NULL DEFAULT 0,
  `showorder` BIGINT NOT NULL DEFAULT 0,
  `hidden` BIGINT NOT NULL DEFAULT 0,
  `retired` BIGINT NOT NULL DEFAULT 0,
  `downloads` TEXT NOT NULL DEFAULT (''),
  `autoactivate` TEXT NOT NULL DEFAULT (''),
  `suspendproduct` BIGINT NOT NULL DEFAULT 0,
  `welcomeemail` BIGINT NOT NULL DEFAULT 0,
  `type` TEXT NOT NULL DEFAULT (''),
  `module` TEXT NOT NULL DEFAULT (''),
  `server_group_id` BIGINT NOT NULL DEFAULT 0,
  `prorate` BIGINT NOT NULL DEFAULT 0,
  `weight` BIGINT NOT NULL DEFAULT 0,
  `autolinkby` TEXT NOT NULL DEFAULT (''),
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbladminlog` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `adminusername` TEXT NOT NULL DEFAULT (''),
  `logintime` DATETIME DEFAULT NULL,
  `logouttime` DATETIME DEFAULT NULL,
  `ipaddress` TEXT NOT NULL DEFAULT (''),
  `lastvisit` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbladminroles` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `widgets` TEXT NOT NULL DEFAULT (''),
  `reports` TEXT NOT NULL DEFAULT (''),
  `systememails` BIGINT NOT NULL DEFAULT 0,
  `accountemails` BIGINT NOT NULL DEFAULT 0,
  `supportemails` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbladmins` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `uuid` TEXT NOT NULL DEFAULT (''),
  `roleid` BIGINT NOT NULL DEFAULT 0,
  `username` TEXT NOT NULL DEFAULT (''),
  `firstname` TEXT NOT NULL DEFAULT (''),
  `lastname` TEXT NOT NULL DEFAULT (''),
  `email` TEXT NOT NULL DEFAULT (''),
  `notes` TEXT NOT NULL DEFAULT (''),
  `template` TEXT NOT NULL DEFAULT (''),
  `language` TEXT NOT NULL DEFAULT (''),
  `disabled` BIGINT NOT NULL DEFAULT 0,
  `loginattempts` BIGINT NOT NULL DEFAULT 0,
  `supportdepts` TEXT NOT NULL DEFAULT (''),
  `ticketnotifications` TEXT NOT NULL DEFAULT (''),
  `homewidgets` TEXT NOT NULL DEFAULT (''),
  `hidden_widgets` TEXT NOT NULL DEFAULT (''),
  `widget_order` TEXT NOT NULL DEFAULT (''),
  `mixpanel_tracking_enabled` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblaffiliates` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `date` DATE NOT NULL DEFAULT '0000-00-00',
  `clientid` BIGINT NOT NULL DEFAULT 0,
  `visitors` BIGINT NOT NULL DEFAULT 0,
  `paytype` TEXT NOT NULL DEFAULT (''),
  `payamount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `onetime` BIGINT NOT NULL DEFAULT 0,
  `balance` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `withdrawn` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblaffiliates_hits` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `affiliate_id` BIGINT NOT NULL DEFAULT 0,
  `referrer_id` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblaffiliates_referrers` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `affiliate_id` BIGINT NOT NULL DEFAULT 0,
  `referrer` TEXT NOT NULL DEFAULT (''),
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblaffiliatesaccounts` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `affiliateid` BIGINT NOT NULL DEFAULT 0,
  `relid` BIGINT NOT NULL DEFAULT 0,
  `lastpaid` DATE NOT NULL DEFAULT '0000-00-00',
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblaffiliateshistory` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `affiliateid` BIGINT NOT NULL DEFAULT 0,
  `date` DATE NOT NULL DEFAULT '0000-00-00',
  `affaccid` BIGINT NOT NULL DEFAULT 0,
  `invoice_id` BIGINT NOT NULL DEFAULT 0,
  `description` TEXT NOT NULL DEFAULT (''),
  `amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblaffiliatespending` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `affaccid` BIGINT NOT NULL DEFAULT 0,
  `invoice_id` BIGINT NOT NULL DEFAULT 0,
  `amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `clearingdate` DATE NOT NULL DEFAULT '0000-00-00',
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblaffiliateswithdrawals` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `affiliateid` BIGINT NOT NULL DEFAULT 0,
  `date` DATE NOT NULL DEFAULT '0000-00-00',
  `amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblannouncements` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `date` DATETIME DEFAULT NULL,
  `title` TEXT NOT NULL DEFAULT (''),
  `announcement` TEXT NOT NULL DEFAULT (''),
  `published` BIGINT NOT NULL DEFAULT 0,
  `parentid` BIGINT NOT NULL DEFAULT 0,
  `language` TEXT NOT NULL DEFAULT (''),
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblbillableitems` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `description` TEXT NOT NULL DEFAULT (''),
  `hours` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `recur` BIGINT NOT NULL DEFAULT 0,
  `recurcycle` TEXT NOT NULL DEFAULT (''),
  `recurfor` BIGINT NOT NULL DEFAULT 0,
  `invoiceaction` BIGINT NOT NULL DEFAULT 0,
  `unit` BIGINT NOT NULL DEFAULT 0,
  `duedate` DATE NOT NULL DEFAULT '0000-00-00',
  `invoicecount` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblbillingnoteitems` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `billingnote_id` BIGINT NOT NULL DEFAULT 0,
  `note_type` TEXT NOT NULL DEFAULT (''),
  `client_id` BIGINT NOT NULL DEFAULT 0,
  `type` TEXT NOT NULL DEFAULT (''),
  `relid` BIGINT NOT NULL DEFAULT 0,
  `description` TEXT NOT NULL DEFAULT (''),
  `amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `taxed` BIGINT NOT NULL DEFAULT 0,
  `tax` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `tax2` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `taxrate` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `taxrate2` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `status` TEXT NOT NULL DEFAULT (''),
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `tblbillingnotes` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `note_type` TEXT NOT NULL DEFAULT (''),
  `custom_number` TEXT NOT NULL DEFAULT (''),
  `client_id` BIGINT NOT NULL DEFAULT 0,
  `date_issued` DATETIME DEFAULT NULL,
  `subtotal` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `tax` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `tax2` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `total` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `taxrate` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `taxrate2` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `status` TEXT NOT NULL DEFAULT (''),
  `notes` TEXT NOT NULL DEFAULT (''),
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `tblcancelrequests` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `date` DATETIME DEFAULT NULL,
  `relid` BIGINT NOT NULL DEFAULT 0,
  `reason` TEXT NOT NULL DEFAULT (''),
  `type` TEXT NOT NULL DEFAULT (''),
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblclientgroups` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `groupname` TEXT NOT NULL DEFAULT (''),
  `groupcolour` TEXT NOT NULL DEFAULT (''),
  `discountpercent` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `susptermexempt` TEXT NOT NULL DEFAULT (''),
  `separateinvoices` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblclients` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `uuid` TEXT NOT NULL DEFAULT (''),
  `firstname` TEXT NOT NULL DEFAULT (''),
  `lastname` TEXT NOT NULL DEFAULT (''),
  `companyname` TEXT NOT NULL DEFAULT (''),
  `email` TEXT NOT NULL DEFAULT (''),
  `address1` TEXT NOT NULL DEFAULT (''),
  `address2` TEXT NOT NULL DEFAULT (''),
  `city` TEXT NOT NULL DEFAULT (''),
  `state` TEXT NOT NULL DEFAULT (''),
  `postcode` TEXT NOT NULL DEFAULT (''),
  `country` TEXT NOT NULL DEFAULT (''),
  `phonenumber` TEXT NOT NULL DEFAULT (''),
  `tax_id` TEXT NOT NULL DEFAULT (''),
  `currency` BIGINT NOT NULL DEFAULT 0,
  `defaultgateway` TEXT NOT NULL DEFAULT (''),
  `credit` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `taxexempt` BIGINT NOT NULL DEFAULT 0,
  `latefeeoveride` BIGINT NOT NULL DEFAULT 0,
  `overideduenotices` BIGINT NOT NULL DEFAULT 0,
  `separateinvoices` BIGINT NOT NULL DEFAULT 0,
  `disableautocc` BIGINT NOT NULL DEFAULT 0,
  `datecreated` DATE NOT NULL DEFAULT '0000-00-00',
  `notes` TEXT NOT NULL DEFAULT (''),
  `billingcid` BIGINT NOT NULL DEFAULT 0,
  `groupid` BIGINT NOT NULL DEFAULT 0,
  `cardtype` TEXT NOT NULL DEFAULT (''),
  `cardlastfour` TEXT NOT NULL DEFAULT (''),
  `bankname` TEXT NOT NULL DEFAULT (''),
  `banktype` TEXT NOT NULL DEFAULT (''),
  `lastlogin` DATETIME DEFAULT NULL,
  `ip` TEXT NOT NULL DEFAULT (''),
  `host` TEXT NOT NULL DEFAULT (''),
  `status` TEXT NOT NULL DEFAULT (''),
  `language` TEXT NOT NULL DEFAULT (''),
  `emailoptout` BIGINT NOT NULL DEFAULT 0,
  `marketing_emails_opt_in` BIGINT NOT NULL DEFAULT 0,
  `overrideautoclose` BIGINT NOT NULL DEFAULT 0,
  `allow_sso` BIGINT NOT NULL DEFAULT 0,
  `email_verified` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  `password` TEXT NOT NULL DEFAULT (''),
  `authdata` TEXT NOT NULL DEFAULT (''),
  `securityqans` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblconfiguration` (
  `id` BIGINT NOT NULL DEFAULT 0 PRIMARY KEY,
  `setting` TEXT NOT NULL DEFAULT (''),
  `value` TEXT NOT NULL DEFAULT ('')
) ENGINE=MyISAM;

CREATE TABLE `tblcontacts` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `firstname` TEXT NOT NULL DEFAULT (''),
  `lastname` TEXT NOT NULL DEFAULT (''),
  `companyname` TEXT NOT NULL DEFAULT (''),
  `email` TEXT NOT NULL DEFAULT (''),
  `address1` TEXT NOT NULL DEFAULT (''),
  `address2` TEXT NOT NULL DEFAULT (''),
  `city` TEXT NOT NULL DEFAULT (''),
  `state` TEXT NOT NULL DEFAULT (''),
  `postcode` TEXT NOT NULL DEFAULT (''),
  `country` TEXT NOT NULL DEFAULT (''),
  `phonenumber` TEXT NOT NULL DEFAULT (''),
  `tax_id` TEXT NOT NULL DEFAULT (''),
  `subaccount` BIGINT NOT NULL DEFAULT 0,
  `permissions` TEXT NOT NULL DEFAULT (''),
  `domainemails` BIGINT NOT NULL DEFAULT 0,
  `generalemails` BIGINT NOT NULL DEFAULT 0,
  `invoiceemails` BIGINT NOT NULL DEFAULT 0,
  `productemails` BIGINT NOT NULL DEFAULT 0,
  `supportemails` BIGINT NOT NULL DEFAULT 0,
  `affiliateemails` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblcredit` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `clientid` BIGINT NOT NULL DEFAULT 0,
  `admin_id` BIGINT NOT NULL DEFAULT 0,
  `date` DATE NOT NULL DEFAULT '0000-00-00',
  `description` TEXT NOT NULL DEFAULT (''),
  `amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `relid` BIGINT NOT NULL DEFAULT 0,
  `billing_note_id` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblcurrencies` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `code` TEXT NOT NULL DEFAULT (''),
  `prefix` TEXT NOT NULL DEFAULT (''),
  `suffix` TEXT NOT NULL DEFAULT (''),
  `format` BIGINT NOT NULL DEFAULT 0,
  `rate` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `default` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblcustomfields` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `type` TEXT NOT NULL DEFAULT (''),
  `relid` BIGINT NOT NULL DEFAULT 0,
  `fieldname` TEXT NOT NULL DEFAULT (''),
  `fieldtype` TEXT NOT NULL DEFAULT (''),
  `description` TEXT NOT NULL DEFAULT (''),
  `fieldoptions` TEXT NOT NULL DEFAULT (''),
  `regexpr` TEXT NOT NULL DEFAULT (''),
  `adminonly` TEXT NOT NULL DEFAULT (''),
  `required` TEXT NOT NULL DEFAULT (''),
  `showorder` TEXT NOT NULL DEFAULT (''),
  `showinvoice` TEXT NOT NULL DEFAULT (''),
  `sortorder` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblcustomfieldsvalues` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `fieldid` BIGINT NOT NULL DEFAULT 0,
  `relid` BIGINT NOT NULL DEFAULT 0,
  `value` TEXT NOT NULL DEFAULT (''),
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbldomain_prefixes` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `prefix` TEXT NOT NULL DEFAULT (''),
  `suffix` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbldomaincats` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `parent_id` BIGINT NOT NULL DEFAULT 0,
  `role_id` BIGINT NOT NULL DEFAULT 0,
  `title` TEXT NOT NULL DEFAULT (''),
  `header` BIGINT NOT NULL DEFAULT 0,
  `order` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbldomainpricing` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `extension` TEXT NOT NULL DEFAULT (''),
  `dnsmanagement` BIGINT NOT NULL DEFAULT 0,
  `emailforwarding` BIGINT NOT NULL DEFAULT 0,
  `idprotection` BIGINT NOT NULL DEFAULT 0,
  `eppcode` BIGINT NOT NULL DEFAULT 0,
  `autoreg` TEXT NOT NULL DEFAULT (''),
  `order` BIGINT NOT NULL DEFAULT 0,
  `group` TEXT NOT NULL DEFAULT (''),
  `grace_period` BIGINT NOT NULL DEFAULT 0,
  `grace_period_fee` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `redemption_grace_period` BIGINT NOT NULL DEFAULT 0,
  `redemption_grace_period_fee` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbldomainpricing_premium` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `to_amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `markup` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbldomains` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `orderid` BIGINT NOT NULL DEFAULT 0,
  `type` TEXT NOT NULL DEFAULT (''),
  `registrationdate` DATE NOT NULL DEFAULT '0000-00-00',
  `domain` TEXT NOT NULL DEFAULT (''),
  `firstpaymentamount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `recurringamount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `registrar` TEXT NOT NULL DEFAULT (''),
  `registrationperiod` BIGINT NOT NULL DEFAULT 0,
  `expirydate` DATE NOT NULL DEFAULT '0000-00-00',
  `promoid` BIGINT NOT NULL DEFAULT 0,
  `status` TEXT NOT NULL DEFAULT (''),
  `nextduedate` DATE NOT NULL DEFAULT '0000-00-00',
  `nextinvoicedate` DATE NOT NULL DEFAULT '0000-00-00',
  `additionalnotes` TEXT NOT NULL DEFAULT (''),
  `paymentmethod` TEXT NOT NULL DEFAULT (''),
  `dnsmanagement` BIGINT NOT NULL DEFAULT 0,
  `emailforwarding` BIGINT NOT NULL DEFAULT 0,
  `idprotection` BIGINT NOT NULL DEFAULT 0,
  `is_premium` BIGINT NOT NULL DEFAULT 0,
  `donotrenew` BIGINT NOT NULL DEFAULT 0,
  `reminders` TEXT NOT NULL DEFAULT (''),
  `synced` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbldomains_categories` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `domain_id` BIGINT NOT NULL DEFAULT 0,
  `parent_id` BIGINT NOT NULL DEFAULT 0,
  `category_id` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblemails` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `subject` TEXT NOT NULL DEFAULT (''),
  `message` TEXT NOT NULL DEFAULT (''),
  `date` DATETIME DEFAULT NULL,
  `to` TEXT NOT NULL DEFAULT (''),
  `pending` BIGINT NOT NULL DEFAULT 0,
  `failed` BIGINT NOT NULL DEFAULT 0,
  `failure_reason` TEXT NOT NULL DEFAULT (''),
  `retry_count` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  `campaign_id` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblemailtemplates` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `type` TEXT NOT NULL DEFAULT (''),
  `name` TEXT NOT NULL DEFAULT (''),
  `subject` TEXT NOT NULL DEFAULT (''),
  `message` TEXT NOT NULL DEFAULT (''),
  `attachments` TEXT NOT NULL DEFAULT (''),
  `fromname` TEXT NOT NULL DEFAULT (''),
  `fromemail` TEXT NOT NULL DEFAULT (''),
  `disabled` BIGINT NOT NULL DEFAULT 0,
  `custom` BIGINT NOT NULL DEFAULT 0,
  `language` TEXT NOT NULL DEFAULT (''),
  `copyto` TEXT NOT NULL DEFAULT (''),
  `blind_copy_to` TEXT NOT NULL DEFAULT (''),
  `plaintext` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblhosting` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `orderid` BIGINT NOT NULL DEFAULT 0,
  `packageid` BIGINT NOT NULL DEFAULT 0,
  `server` BIGINT NOT NULL DEFAULT 0,
  `regdate` DATE NOT NULL DEFAULT '0000-00-00',
  `domain` TEXT NOT NULL DEFAULT (''),
  `paymentmethod` TEXT NOT NULL DEFAULT (''),
  `qty` BIGINT NOT NULL DEFAULT 0,
  `firstpaymentamount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `billingcycle` TEXT NOT NULL DEFAULT (''),
  `nextduedate` DATE NOT NULL DEFAULT '0000-00-00',
  `nextinvoicedate` DATE NOT NULL DEFAULT '0000-00-00',
  `termination_date` DATE NOT NULL DEFAULT '0000-00-00',
  `completed_date` DATE NOT NULL DEFAULT '0000-00-00',
  `domainstatus` TEXT NOT NULL DEFAULT (''),
  `notes` TEXT NOT NULL DEFAULT (''),
  `recommendation_source_product_id` BIGINT NOT NULL DEFAULT 0,
  `promoid` BIGINT NOT NULL DEFAULT 0,
  `promocount` BIGINT NOT NULL DEFAULT 0,
  `suspendreason` TEXT NOT NULL DEFAULT (''),
  `overideautosuspend` BIGINT NOT NULL DEFAULT 0,
  `overidesuspenduntil` DATE NOT NULL DEFAULT '0000-00-00',
  `dedicatedip` TEXT NOT NULL DEFAULT (''),
  `assignedips` TEXT NOT NULL DEFAULT (''),
  `ns1` TEXT NOT NULL DEFAULT (''),
  `ns2` TEXT NOT NULL DEFAULT (''),
  `diskusage` BIGINT NOT NULL DEFAULT 0,
  `disklimit` BIGINT NOT NULL DEFAULT 0,
  `bwusage` BIGINT NOT NULL DEFAULT 0,
  `bwlimit` BIGINT NOT NULL DEFAULT 0,
  `upsell_from_products` TEXT NOT NULL DEFAULT (''),
  `lastupdate` DATETIME DEFAULT NULL,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  `password` TEXT NOT NULL DEFAULT (''),
  `username` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblhostingaddons` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `orderid` BIGINT NOT NULL DEFAULT 0,
  `hostingid` BIGINT NOT NULL DEFAULT 0,
  `addonid` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `server` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `qty` BIGINT NOT NULL DEFAULT 0,
  `firstpaymentamount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `setupfee` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `recurring` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `billingcycle` TEXT NOT NULL DEFAULT (''),
  `tax` TEXT NOT NULL DEFAULT (''),
  `status` TEXT NOT NULL DEFAULT (''),
  `regdate` DATE NOT NULL DEFAULT '0000-00-00',
  `nextduedate` DATE NOT NULL DEFAULT '0000-00-00',
  `nextinvoicedate` DATE NOT NULL DEFAULT '0000-00-00',
  `termination_date` DATE NOT NULL DEFAULT '0000-00-00',
  `proratadate` DATE NOT NULL DEFAULT '0000-00-00',
  `paymentmethod` TEXT NOT NULL DEFAULT (''),
  `notes` TEXT NOT NULL DEFAULT (''),
  `upsell_from_products` TEXT NOT NULL DEFAULT (''),
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblhostingconfigoptions` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `relid` BIGINT NOT NULL DEFAULT 0,
  `configid` BIGINT NOT NULL DEFAULT 0,
  `optionid` BIGINT NOT NULL DEFAULT 0,
  `qty` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblinvoiceitems` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `invoiceid` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `type` TEXT NOT NULL DEFAULT (''),
  `relid` BIGINT NOT NULL DEFAULT 0,
  `description` TEXT NOT NULL DEFAULT (''),
  `amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `taxed` BIGINT NOT NULL DEFAULT 0,
  `duedate` DATE NOT NULL DEFAULT '0000-00-00',
  `paymentmethod` TEXT NOT NULL DEFAULT (''),
  `notes` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblinvoices` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `invoicenum` TEXT NOT NULL DEFAULT (''),
  `date` DATE NOT NULL DEFAULT '0000-00-00',
  `duedate` DATE NOT NULL DEFAULT '0000-00-00',
  `datepaid` DATETIME DEFAULT NULL,
  `last_capture_attempt` DATETIME DEFAULT NULL,
  `date_refunded` DATETIME DEFAULT NULL,
  `date_cancelled` DATETIME DEFAULT NULL,
  `subtotal` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `credit` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `tax` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `tax2` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `total` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `taxrate` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `taxrate2` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `status` TEXT NOT NULL DEFAULT (''),
  `paymentmethod` TEXT NOT NULL DEFAULT (''),
  `paymethodid` BIGINT NOT NULL DEFAULT 0,
  `notes` TEXT NOT NULL DEFAULT (''),
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblnotes` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `adminid` BIGINT NOT NULL DEFAULT 0,
  `created` DATETIME DEFAULT NULL,
  `modified` DATETIME DEFAULT NULL,
  `note` TEXT NOT NULL DEFAULT (''),
  `sticky` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblorders` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `ordernum` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `contactid` BIGINT NOT NULL DEFAULT 0,
  `requestor_id` BIGINT NOT NULL DEFAULT 0,
  `admin_requestor_id` BIGINT NOT NULL DEFAULT 0,
  `date` DATETIME DEFAULT NULL,
  `nameservers` TEXT NOT NULL DEFAULT (''),
  `renewals` TEXT NOT NULL DEFAULT (''),
  `promocode` TEXT NOT NULL DEFAULT (''),
  `promotype` TEXT NOT NULL DEFAULT (''),
  `promovalue` TEXT NOT NULL DEFAULT (''),
  `amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `paymentmethod` TEXT NOT NULL DEFAULT (''),
  `invoiceid` BIGINT NOT NULL DEFAULT 0,
  `status` TEXT NOT NULL DEFAULT (''),
  `ipaddress` TEXT NOT NULL DEFAULT (''),
  `fraudmodule` TEXT NOT NULL DEFAULT (''),
  `notes` TEXT NOT NULL DEFAULT (''),
  `purchase_source` BIGINT NOT NULL DEFAULT 0,
  `has_referral_products` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblorderstatuses` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `title` TEXT NOT NULL DEFAULT (''),
  `color` TEXT NOT NULL DEFAULT (''),
  `showpending` BIGINT NOT NULL DEFAULT 0,
  `showactive` BIGINT NOT NULL DEFAULT 0,
  `showcancelled` BIGINT NOT NULL DEFAULT 0,
  `sortorder` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblpaymentgateways` (
  `id` BIGINT NOT NULL DEFAULT 0 PRIMARY KEY,
  `gateway` TEXT NOT NULL DEFAULT (''),
  `setting` TEXT NOT NULL DEFAULT (''),
  `value` TEXT NOT NULL DEFAULT (''),
  `order` BIGINT NOT NULL DEFAULT 0
) ENGINE=MyISAM;

CREATE TABLE `tblpricing` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `type` TEXT NOT NULL DEFAULT (''),
  `currency` BIGINT NOT NULL DEFAULT 0,
  `relid` BIGINT NOT NULL DEFAULT 0,
  `msetupfee` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `qsetupfee` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `ssetupfee` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `asetupfee` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `bsetupfee` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `tsetupfee` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `monthly` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `quarterly` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `semiannually` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `annually` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `biennially` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `triennially` DECIMAL(18,4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblproductconfiggroups` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `description` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblproductconfiglinks` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `gid` BIGINT NOT NULL DEFAULT 0,
  `pid` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblproductconfigoptions` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `gid` BIGINT NOT NULL DEFAULT 0,
  `optionname` TEXT NOT NULL DEFAULT (''),
  `optiontype` TEXT NOT NULL DEFAULT (''),
  `qtyminimum` BIGINT NOT NULL DEFAULT 0,
  `qtymaximum` BIGINT NOT NULL DEFAULT 0,
  `order` BIGINT NOT NULL DEFAULT 0,
  `hidden` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblproductconfigoptionssub` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `configid` BIGINT NOT NULL DEFAULT 0,
  `optionname` TEXT NOT NULL DEFAULT (''),
  `sortorder` BIGINT NOT NULL DEFAULT 0,
  `hidden` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblproductgroups` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `slug` TEXT NOT NULL DEFAULT (''),
  `headline` TEXT NOT NULL DEFAULT (''),
  `tagline` TEXT NOT NULL DEFAULT (''),
  `orderfrmtpl` TEXT NOT NULL DEFAULT (''),
  `disabledgateways` TEXT NOT NULL DEFAULT (''),
  `hidden` BIGINT NOT NULL DEFAULT 0,
  `order` BIGINT NOT NULL DEFAULT 0,
  `icon` TEXT NOT NULL DEFAULT (''),
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblproducts` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `type` TEXT NOT NULL DEFAULT (''),
  `gid` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `slug` TEXT NOT NULL DEFAULT (''),
  `description` TEXT NOT NULL DEFAULT (''),
  `hidden` BIGINT NOT NULL DEFAULT 0,
  `showdomainoptions` BIGINT NOT NULL DEFAULT 0,
  `welcomeemail` BIGINT NOT NULL DEFAULT 0,
  `stockcontrol` BIGINT NOT NULL DEFAULT 0,
  `qty` BIGINT NOT NULL DEFAULT 0,
  `proratabilling` BIGINT NOT NULL DEFAULT 0,
  `proratadate` BIGINT NOT NULL DEFAULT 0,
  `proratachargenextmonth` BIGINT NOT NULL DEFAULT 0,
  `paytype` TEXT NOT NULL DEFAULT (''),
  `allowqty` BIGINT NOT NULL DEFAULT 0,
  `subdomain` TEXT NOT NULL DEFAULT (''),
  `autosetup` TEXT NOT NULL DEFAULT (''),
  `servertype` TEXT NOT NULL DEFAULT (''),
  `servergroup` BIGINT NOT NULL DEFAULT 0,
  `freedomain` TEXT NOT NULL DEFAULT (''),
  `freedomainpaymentterms` TEXT NOT NULL DEFAULT (''),
  `freedomaintlds` TEXT NOT NULL DEFAULT (''),
  `recurringcycles` BIGINT NOT NULL DEFAULT 0,
  `autoterminatedays` BIGINT NOT NULL DEFAULT 0,
  `autoterminateemail` BIGINT NOT NULL DEFAULT 0,
  `configoptionsupgrade` BIGINT NOT NULL DEFAULT 0,
  `billingcycleupgrade` TEXT NOT NULL DEFAULT (''),
  `upgradeemail` BIGINT NOT NULL DEFAULT 0,
  `overagesenabled` TEXT NOT NULL DEFAULT (''),
  `overagesdisklimit` BIGINT NOT NULL DEFAULT 0,
  `overagesbwlimit` BIGINT NOT NULL DEFAULT 0,
  `overagesdiskprice` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `overagesbwprice` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `tax` BIGINT NOT NULL DEFAULT 0,
  `affiliateonetime` BIGINT NOT NULL DEFAULT 0,
  `affiliatepaytype` TEXT NOT NULL DEFAULT (''),
  `affiliatepayamount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `order` BIGINT NOT NULL DEFAULT 0,
  `retired` BIGINT NOT NULL DEFAULT 0,
  `is_featured` BIGINT NOT NULL DEFAULT 0,
  `color` TEXT NOT NULL DEFAULT (''),
  `tagline` TEXT NOT NULL DEFAULT (''),
  `short_description` TEXT NOT NULL DEFAULT (''),
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  `configoption1` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblpromotions` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `code` TEXT NOT NULL DEFAULT (''),
  `type` TEXT NOT NULL DEFAULT (''),
  `recurring` BIGINT NOT NULL DEFAULT 0,
  `value` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `cycles` TEXT NOT NULL DEFAULT (''),
  `appliesto` TEXT NOT NULL DEFAULT (''),
  `requires` TEXT NOT NULL DEFAULT (''),
  `requiresexisting` BIGINT NOT NULL DEFAULT 0,
  `startdate` DATE NOT NULL DEFAULT '0000-00-00',
  `expirationdate` DATE NOT NULL DEFAULT '0000-00-00',
  `maxuses` BIGINT NOT NULL DEFAULT 0,
  `uses` BIGINT NOT NULL DEFAULT 0,
  `lifetimepromo` BIGINT NOT NULL DEFAULT 0,
  `applyonce` BIGINT NOT NULL DEFAULT 0,
  `newsignups` BIGINT NOT NULL DEFAULT 0,
  `existingclient` BIGINT NOT NULL DEFAULT 0,
  `onceperclient` BIGINT NOT NULL DEFAULT 0,
  `recurfor` BIGINT NOT NULL DEFAULT 0,
  `upgrades` BIGINT NOT NULL DEFAULT 0,
  `notes` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblquoteitems` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `quoteid` BIGINT NOT NULL DEFAULT 0,
  `description` TEXT NOT NULL DEFAULT (''),
  `quantity` TEXT NOT NULL DEFAULT (''),
  `unitprice` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `discount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `taxable` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblquotes` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `subject` TEXT NOT NULL DEFAULT (''),
  `stage` TEXT NOT NULL DEFAULT (''),
  `validuntil` DATE NOT NULL DEFAULT '0000-00-00',
  `userid` BIGINT NOT NULL DEFAULT 0,
  `firstname` TEXT NOT NULL DEFAULT (''),
  `lastname` TEXT NOT NULL DEFAULT (''),
  `companyname` TEXT NOT NULL DEFAULT (''),
  `email` TEXT NOT NULL DEFAULT (''),
  `address1` TEXT NOT NULL DEFAULT (''),
  `address2` TEXT NOT NULL DEFAULT (''),
  `city` TEXT NOT NULL DEFAULT (''),
  `state` TEXT NOT NULL DEFAULT (''),
  `postcode` TEXT NOT NULL DEFAULT (''),
  `country` TEXT NOT NULL DEFAULT (''),
  `phonenumber` TEXT NOT NULL DEFAULT (''),
  `tax_id` TEXT NOT NULL DEFAULT (''),
  `currency` BIGINT NOT NULL DEFAULT 0,
  `subtotal` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `tax1` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `tax2` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `total` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `proposal` TEXT NOT NULL DEFAULT (''),
  `customernotes` TEXT NOT NULL DEFAULT (''),
  `adminnotes` TEXT NOT NULL DEFAULT (''),
  `datecreated` DATE NOT NULL DEFAULT '0000-00-00',
  `lastmodified` DATE NOT NULL DEFAULT '0000-00-00',
  `datesent` DATE NOT NULL DEFAULT '0000-00-00',
  `dateaccepted` DATE NOT NULL DEFAULT '0000-00-00',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblregistrars` (
  `registrar` TEXT NOT NULL DEFAULT (''),
  `id` BIGINT NOT NULL DEFAULT 0,
  `setting` TEXT NOT NULL DEFAULT (''),
  `value` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblreversedinvoiceitems` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `invoiceid` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `description` TEXT NOT NULL DEFAULT (''),
  `amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `duedate` DATE NOT NULL DEFAULT '0000-00-00',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblreversedinvoices` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `date` DATE NOT NULL DEFAULT '0000-00-00',
  `duedate` DATE NOT NULL DEFAULT '0000-00-00',
  `subtotal` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `tax` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `total` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `taxrate` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `original_invoice_id` TEXT NOT NULL DEFAULT (''),
  `reverse_date` DATE NOT NULL DEFAULT '0000-00-00',
  `notes` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblservergroups` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `filltype` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblservergroupsrel` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `groupid` BIGINT NOT NULL DEFAULT 0,
  `serverid` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblservers` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `ipaddress` TEXT NOT NULL DEFAULT (''),
  `assignedips` TEXT NOT NULL DEFAULT (''),
  `hostname` TEXT NOT NULL DEFAULT (''),
  `monthlycost` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `noc` TEXT NOT NULL DEFAULT (''),
  `statusaddress` TEXT NOT NULL DEFAULT (''),
  `nameserver1` TEXT NOT NULL DEFAULT (''),
  `nameserver1ip` TEXT NOT NULL DEFAULT (''),
  `nameserver2` TEXT NOT NULL DEFAULT (''),
  `nameserver2ip` TEXT NOT NULL DEFAULT (''),
  `nameserver3` TEXT NOT NULL DEFAULT (''),
  `nameserver3ip` TEXT NOT NULL DEFAULT (''),
  `nameserver4` TEXT NOT NULL DEFAULT (''),
  `nameserver4ip` TEXT NOT NULL DEFAULT (''),
  `nameserver5` TEXT NOT NULL DEFAULT (''),
  `nameserver5ip` TEXT NOT NULL DEFAULT (''),
  `maxaccounts` BIGINT NOT NULL DEFAULT 0,
  `type` TEXT NOT NULL DEFAULT (''),
  `secure` TEXT NOT NULL DEFAULT (''),
  `port` BIGINT NOT NULL DEFAULT 0,
  `active` BIGINT NOT NULL DEFAULT 0,
  `disabled` BIGINT NOT NULL DEFAULT 0,
  `password` TEXT NOT NULL DEFAULT (''),
  `username` TEXT NOT NULL DEFAULT (''),
  `accesshash` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblsslstatus` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `user_id` BIGINT NOT NULL DEFAULT 0,
  `domain_name` TEXT NOT NULL DEFAULT (''),
  `subject_name` TEXT NOT NULL DEFAULT (''),
  `subject_org` TEXT NOT NULL DEFAULT (''),
  `issuer_name` TEXT NOT NULL DEFAULT (''),
  `issuer_org` TEXT NOT NULL DEFAULT (''),
  `start_date` DATETIME DEFAULT NULL,
  `expiry_date` DATETIME DEFAULT NULL,
  `active` BIGINT NOT NULL DEFAULT 0,
  `last_synced_date` DATETIME DEFAULT NULL,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbltax` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `level` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `state` TEXT NOT NULL DEFAULT (''),
  `country` TEXT NOT NULL DEFAULT (''),
  `taxrate` DECIMAL(18,4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblticket_watchers` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `ticket_id` BIGINT NOT NULL DEFAULT 0,
  `admin_id` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblticketdepartments` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `description` TEXT NOT NULL DEFAULT (''),
  `email` TEXT NOT NULL DEFAULT (''),
  `clientsonly` TEXT NOT NULL DEFAULT (''),
  `piperepliesonly` TEXT NOT NULL DEFAULT (''),
  `noautoresponder` TEXT NOT NULL DEFAULT (''),
  `hidden` TEXT NOT NULL DEFAULT (''),
  `order` BIGINT NOT NULL DEFAULT 0,
  `feedback_request` BIGINT NOT NULL DEFAULT 0,
  `prevent_client_closure` BIGINT NOT NULL DEFAULT 0,
  `mail_import_message_cap` BIGINT NOT NULL DEFAULT 0,
  `mail_import_total_attachment_mb` BIGINT NOT NULL DEFAULT 0,
  `mail_import_max_attachment_mb` BIGINT NOT NULL DEFAULT 0,
  `password` TEXT NOT NULL DEFAULT (''),
  `mail_auth_config` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblticketfeedback` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `ticketid` BIGINT NOT NULL DEFAULT 0,
  `adminid` BIGINT NOT NULL DEFAULT 0,
  `rating` BIGINT NOT NULL DEFAULT 0,
  `comments` TEXT NOT NULL DEFAULT (''),
  `datetime` DATETIME DEFAULT NULL,
  `ip` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblticketlog` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `date` DATETIME DEFAULT NULL,
  `tid` BIGINT NOT NULL DEFAULT 0,
  `action` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblticketnotes` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `ticketid` BIGINT NOT NULL DEFAULT 0,
  `admin` TEXT NOT NULL DEFAULT (''),
  `date` DATETIME DEFAULT NULL,
  `message` TEXT NOT NULL DEFAULT (''),
  `attachments` TEXT NOT NULL DEFAULT (''),
  `attachments_removed` BIGINT NOT NULL DEFAULT 0,
  `editor` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblticketpredefinedcats` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `parentid` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblticketpredefinedreplies` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `catid` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `reply` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblticketreplies` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `tid` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `contactid` BIGINT NOT NULL DEFAULT 0,
  `requestor_id` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `email` TEXT NOT NULL DEFAULT (''),
  `date` DATETIME DEFAULT NULL,
  `message` TEXT NOT NULL DEFAULT (''),
  `admin` TEXT NOT NULL DEFAULT (''),
  `attachment` TEXT NOT NULL DEFAULT (''),
  `attachments_removed` BIGINT NOT NULL DEFAULT 0,
  `rating` BIGINT NOT NULL DEFAULT 0,
  `editor` TEXT NOT NULL DEFAULT (''),
  `agent_score` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbltickets` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `tid` TEXT NOT NULL DEFAULT (''),
  `did` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `contactid` BIGINT NOT NULL DEFAULT 0,
  `requestor_id` BIGINT NOT NULL DEFAULT 0,
  `prevent_client_closure` BIGINT NOT NULL DEFAULT 0,
  `name` TEXT NOT NULL DEFAULT (''),
  `email` TEXT NOT NULL DEFAULT (''),
  `cc` TEXT NOT NULL DEFAULT (''),
  `ipaddress` TEXT NOT NULL DEFAULT (''),
  `date` DATETIME DEFAULT NULL,
  `title` TEXT NOT NULL DEFAULT (''),
  `message` TEXT NOT NULL DEFAULT (''),
  `status` TEXT NOT NULL DEFAULT (''),
  `urgency` TEXT NOT NULL DEFAULT (''),
  `admin` TEXT NOT NULL DEFAULT (''),
  `attachment` TEXT NOT NULL DEFAULT (''),
  `attachments_removed` BIGINT NOT NULL DEFAULT 0,
  `lastreply` DATETIME DEFAULT NULL,
  `flag` BIGINT NOT NULL DEFAULT 0,
  `clientunread` BIGINT NOT NULL DEFAULT 0,
  `adminunread` TEXT NOT NULL DEFAULT (''),
  `replyingadmin` BIGINT NOT NULL DEFAULT 0,
  `replyingtime` DATETIME DEFAULT NULL,
  `service` TEXT NOT NULL DEFAULT (''),
  `merged_ticket_id` BIGINT NOT NULL DEFAULT 0,
  `editor` TEXT NOT NULL DEFAULT (''),
  `pinned_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  `c` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblticketstatuses` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `title` TEXT NOT NULL DEFAULT (''),
  `color` TEXT NOT NULL DEFAULT (''),
  `sortorder` BIGINT NOT NULL DEFAULT 0,
  `showactive` BIGINT NOT NULL DEFAULT 0,
  `showawaiting` BIGINT NOT NULL DEFAULT 0,
  `autoclose` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbltickettags` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `ticketid` BIGINT NOT NULL DEFAULT 0,
  `tag` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tbltodolist` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `date` DATE NOT NULL DEFAULT '0000-00-00',
  `title` TEXT NOT NULL DEFAULT (''),
  `description` TEXT NOT NULL DEFAULT (''),
  `admin` BIGINT NOT NULL DEFAULT 0,
  `status` TEXT NOT NULL DEFAULT (''),
  `duedate` DATE NOT NULL DEFAULT '0000-00-00',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblupgrades` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `userid` BIGINT NOT NULL DEFAULT 0,
  `orderid` BIGINT NOT NULL DEFAULT 0,
  `type` TEXT NOT NULL DEFAULT (''),
  `date` DATE NOT NULL DEFAULT '0000-00-00',
  `relid` BIGINT NOT NULL DEFAULT 0,
  `originalvalue` TEXT NOT NULL DEFAULT (''),
  `newvalue` TEXT NOT NULL DEFAULT (''),
  `new_cycle` TEXT NOT NULL DEFAULT (''),
  `amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `credit_amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `days_remaining` BIGINT NOT NULL DEFAULT 0,
  `total_days_in_cycle` BIGINT NOT NULL DEFAULT 0,
  `new_recurring_amount` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `recurringchange` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `status` TEXT NOT NULL DEFAULT (''),
  `paid` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblusage_items` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `rel_type` TEXT NOT NULL DEFAULT (''),
  `rel_id` BIGINT NOT NULL DEFAULT 0,
  `module_type` TEXT NOT NULL DEFAULT (''),
  `module` TEXT NOT NULL DEFAULT (''),
  `metric` TEXT NOT NULL DEFAULT (''),
  `included` DECIMAL(18,4) NOT NULL DEFAULT 0,
  `is_hidden` BIGINT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  `deleted_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `tblusers` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `first_name` TEXT NOT NULL DEFAULT (''),
  `last_name` TEXT NOT NULL DEFAULT (''),
  `email` TEXT NOT NULL DEFAULT (''),
  `language` TEXT NOT NULL DEFAULT (''),
  `last_ip` TEXT NOT NULL DEFAULT (''),
  `last_hostname` TEXT NOT NULL DEFAULT (''),
  `last_login` DATETIME DEFAULT NULL,
  `email_verified_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  `password` TEXT NOT NULL DEFAULT (''),
  `security_question_answer` TEXT NOT NULL DEFAULT (''),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `tblusers_clients` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `auth_user_id` BIGINT NOT NULL DEFAULT 0,
  `client_id` BIGINT NOT NULL DEFAULT 0,
  `owner` BIGINT NOT NULL DEFAULT 0,
  `permissions` TEXT NOT NULL DEFAULT (''),
  `last_login` DATETIME DEFAULT NULL,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
