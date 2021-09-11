
FROM debian:buster-slim

RUN apt-get update -y && apt-get install -y git
RUN git clone https://github.com/nginxinc/nginx-ldap-auth

FROM debian:buster-slim

RUN apt-get update -y && apt-get install -y python-ldap
COPY --from=0 /nginx-ldap-auth/nginx-ldap-auth-daemon.py /app/

EXPOSE 8888

ENTRYPOINT ["python", "/app/nginx-ldap-auth-daemon.py", "--host", "0.0.0.0", "--port", "8888"]
