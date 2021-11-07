
# Generate hashed password for using in `.ldif` file

```bash
slappasswd -s 'mypassword'
```

# Add a user stored in a `.ldif` file into openldap

```bash
ldapadd -h localhost -p 10389 -D 'cn=admin,dc=lab,dc=tintinho,dc=net' -w 'password1234' -f testuser.ldif
```