#!/usr/bin/env python3
"""Load representative fixture DDL and synthetic records, never customer data."""
from pathlib import Path
import sys

source = Path(sys.argv[1] if len(sys.argv)>1 else 'test/fixture-schema.sql')
print("SET SESSION sql_mode='';")
collecting = False
count = 0
with source.open() as f:
    for line in f:
        if line.startswith('CREATE TABLE '):
            collecting = True
            count += 1
        if collecting:
            print(line, end='')
            if line.rstrip().endswith(';'):
                collecting = False
if count == 0:
    raise SystemExit('No DDL found')
print("""
INSERT INTO tblconfiguration (id,setting,value) VALUES (1,'Version','9.0.0'),(2,'CompanyName','Synthetic fixture'),(3,'SMTPPassword','CANARY_CONFIGURATION_SECRET');
INSERT INTO tblcurrencies (id,code,rate) VALUES (1,'GBP',1),(2,'EUR',1.2);
INSERT INTO tblclients (id,firstname,lastname,email,currency,status,credit,password,authdata,securityqans) VALUES
 (1,'Synthetic','Alpha','alpha@example.invalid',1,'Active',10,'CANARY_CLIENT_PASSWORD','CANARY_AUTH_DATA','CANARY_SECURITY_ANSWER'),
 (2,'Synthetic','Beta','beta@example.invalid',2,'Active',0,'CANARY_OTHER_PASSWORD','','');
INSERT INTO tblusers (id,first_name,last_name,email,password,security_question_answer) VALUES (1,'Synthetic','Alpha','alpha@example.invalid','CANARY_USER_PASSWORD','CANARY_USER_ANSWER');
INSERT INTO tblusers_clients (id,auth_user_id,client_id,owner) VALUES (1,1,1,1);
INSERT INTO tblproducts (id,gid,name,paytype,configoption1) VALUES (1,1,'Synthetic Hosting','recurring','CANARY_MODULE_CONFIG');
INSERT INTO tblproductgroups (id,name) VALUES (1,'Synthetic Products');
INSERT INTO tblhosting (id,userid,packageid,domain,amount,billingcycle,domainstatus,nextduedate,password,username) VALUES
 (1,1,1,'alpha.example.invalid',120,'Annually','Active','2030-01-15','CANARY_HOSTING_PASSWORD','CANARY_HOSTING_LOGIN'),
 (2,1,1,'suspended.example.invalid',99,'Monthly','Suspended','2030-01-15','',''),
 (3,2,1,'beta.example.invalid',20,'Monthly','Active','2030-01-15','',''),
 (4,1,1,'onetime.example.invalid',500,'One Time','Active','2030-01-15','','');
INSERT INTO tblhostingaddons (id,userid,hostingid,addonid,recurring,billingcycle,status) VALUES (1,1,1,1,24,'Annually','Active');
INSERT INTO tblinvoices (id,userid,date,duedate,total,subtotal,credit,status) VALUES
 (1,1,'2020-01-01','2020-01-15',100,100,10,'Unpaid'),
 (2,1,'2020-01-01','2020-01-15',100,100,0,'Paid'),
 (3,2,'2020-01-01','2020-01-15',200,200,0,'Unpaid'),
 (4,1,'2020-01-01','2020-01-15',300,300,0,'Cancelled'),
 (5,1,'2020-01-01','0000-00-00',50,50,0,'Unpaid'),
 (6,1,'2020-01-01','2020-01-15',100,100,0,'Unpaid');
INSERT INTO tblinvoiceitems (id,invoiceid,userid,description,amount) VALUES (1,1,1,'Synthetic item A',60),(2,1,1,'Synthetic item B',40);
INSERT INTO tblaccounts (id,userid,currency,date,amountin,amountout,fees,invoiceid,transid) VALUES
 (1,1,1,'2020-01-10 12:00:00',30,0,1,1,'synthetic-1'),
 (2,1,1,'2020-01-11 12:00:00',20,0,0,1,'synthetic-2'),
 (3,1,1,'2020-01-12 12:00:00',0,5,0,1,'synthetic-refund'),
 (4,1,1,'2020-01-10 12:00:00',100,0,2,2,'synthetic-paid'),
 (5,2,2,'2020-01-10 12:00:00',25,0,0,3,'synthetic-eur'),
 (6,1,2,'2020-01-10 12:00:00',10,0,0,6,'synthetic-mismatched-currency');
INSERT INTO tblticketdepartments (id,name,email,password,mail_auth_config) VALUES (1,'Synthetic Support','support@example.invalid','CANARY_MAIL_PASSWORD','CANARY_MAIL_AUTH');
INSERT INTO tbltickets (id,tid,did,userid,title,message,status,urgency,c,date,attachment) VALUES (1,'SYN-000001',1,1,'Synthetic ticket','Example business content','Open','High','CANARY_TICKET_ACCESS_SECRET','2020-01-01','CANARY_ATTACHMENT_PATH');
INSERT INTO tblticketreplies (id,tid,userid,message,date) VALUES (1,1,1,'Synthetic reply','2020-01-02');
INSERT INTO tblticketnotes (id,ticketid,message,date) VALUES (1,1,'Synthetic staff note','2020-01-03');
INSERT INTO tblservers (id,name,hostname,password,username,accesshash) VALUES (1,'Synthetic Server','server.example.invalid','CANARY_SERVER_PASSWORD','CANARY_SERVER_LOGIN','CANARY_SERVER_HASH');
INSERT INTO tblpaymentgateways (id,gateway,setting,value) VALUES (1,'synthetic','name','Synthetic Gateway'),(2,'synthetic','secret','CANARY_GATEWAY_SECRET');
INSERT INTO tblregistrars (id,registrar,setting,value) VALUES (1,'synthetic','password','CANARY_REGISTRAR_PASSWORD');
INSERT INTO tblcustomfields (id,type,fieldname,fieldtype) VALUES (1,'client','Business label','text'),(2,'client','Portal password','password'),(3,'client','API Key','text');
INSERT INTO tblcustomfieldsvalues (id,fieldid,relid,value) VALUES (1,1,1,'Synthetic label'),(2,2,1,'CANARY_CUSTOM_PASSWORD'),(3,3,1,'CANARY_CUSTOM_API_KEY');
""")
