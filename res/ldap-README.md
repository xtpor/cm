
# Generate hashed password for using in `.ldif` file

```bash
slappasswd -s 'mypassword'
```

# Add a user stored in a `.ldif` file into openldap

```bash
ldapadd -h localhost -p 10389 -D 'cn=admin,dc=lab,dc=tintinho,dc=net' -w 'password1234' -f testuser.ldif
```

# Login OpenLDAP

```
cn=admin,dc=lab,dc=tintinho,dc=net
adminpassword

cn=admin,cn=config
configpassword

cn=readonly,dc=lab,dc=tintinho,dc=net
readonlypassword
```

# List the content in the config database

```
ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b cn=config
```

# Changing the password for the `config` account

```
dn: olcDatabase={0}config,cn=config
changetype: modify
replace: olcRootDN
olcRootPW: confignewpassword
```

# Changing the password for the `admin` account

```
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: adminnewpassword
```

ldapmodify -H ldapi:// -Y EXTERNAL -f ~/newpasswd.ldif