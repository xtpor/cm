
# Postgres Database Management

## connecting to the database

```
psql -h <host> -p <port> -U <user> -W
```

## some hardening to do after creating a new database cluster

```sql
-- only allow CONNECT to the `postgres` database
REVOKE ALL PRIVILEGES ON DATABASE postgres FROM PUBLIC;
GRANT CONNECT ON DATABASE postgres TO PUBLIC;

-- disallow doing anything on the `postgres.public`
\c postgres
REVOKE ALL PRIVILEGES ON SCHEMA public FROM PUBLIC;
```

## provision a new database

```sql
CREATE DATABASE mydb;
REVOKE ALL PRIVILEGES ON DATABASE mydb FROM PUBLIC;

\c mydb
REVOKE ALL PRIVILEGES ON SCHEMA public FROM PUBLIC;
```

## create a admin user for a newly created database

```sql
CREATE USER myuser WITH PASSWORD 'mypassword';
ALTER DATABASE mydb OWNER TO myuser;
GRANT ALL PRIVILEGES ON DATABASE mydb to myuser;

\c mydb
ALTER SCHEMA public OWNER TO myuser;
GRANT ALL PRIVILEGES ON SCHEMA public to myuser;
```

```sql
GRANT ALL PRIVILEGES ON DATABASE mydb to myuser;
```


```sql
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
```


CREATE DATABASE mydb;
CREATE USER myuser WITH PASSWORD 'mypassword';
GRANT ALL PRIVILEGES ON DATABASE mydb to myuser;


CREATE ROLE gitea-admin NOLOGIN;

GRANT group_role TO role1;


for a database

admin
readwrite
readonly

https://aws.amazon.com/tw/blogs/database/managing-postgresql-users-and-roles/

https://blog.hagander.net/faking-the-dbo-role-70/

create default permission