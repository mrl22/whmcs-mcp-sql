# Direct database integration without an installed WHMCS plugin

The server runs in Docker and reads WHMCS data directly through MySQL, avoiding dependency on WHMCS API credentials, installed plugins or application filesystem access. Its scope is exclusively reading and analysing stored data. It provides no functionality to create, edit or delete WHMCS data, send messages, provision services, or change registrar state. Stored records cannot establish that an external operation completed.
