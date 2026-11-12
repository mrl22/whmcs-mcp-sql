# WHMCS Operations

Language for the client management, billing, support, and hosting operations exposed by this project.

## Language

**Client**:
The customer account that owns services, domains, invoices, and support tickets.
_Avoid_: User, login account

**User**:
A person with a login who may have access to one or more client accounts.
_Avoid_: Client

**Service**:
A product instance supplied to a client, such as a hosting account.
_Avoid_: Product, server

**Product**:
A catalog offering from which a client service can be ordered.
_Avoid_: Service

**Provisioning action**:
An operation that creates, suspends, restores, terminates, or changes the supplied hosting service.
_Avoid_: Status edit

**Recent login**:
A recorded client login or staff activity within a specified time window; it does not establish that a person is currently connected.
_Avoid_: Online session

**Outstanding balance**:
The remaining invoice amount after applied credit and net recorded payments, expressed in one currency. An unresolved currency mismatch prevents a reliable balance.
_Avoid_: Invoice total

**Monthly recurring revenue (MRR)**:
The current recurring service and addon charges normalized to a monthly amount. It is a forecast indicator, distinct from money received or recognized accounting revenue.
_Avoid_: Cash receipts, invoice revenue
