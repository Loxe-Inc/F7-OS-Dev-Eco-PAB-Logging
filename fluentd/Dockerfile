FROM fluent/fluentd:edge-debian
USER root
RUN ["mkdir", "-p", "/home/fluent"]
RUN ["chown", "-R", "fluent:fluent", "/home/fluent"]
RUN apt-get update && apt-get install -y build-essential libssl-dev libxml2-dev libxslt1-dev ruby-dev
RUN ["chown", "-R", "fluent:fluent", "/usr/local"]
USER fluent
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-document", "--version", "5.2.2"]
RUN ["fluent-gem", "install", "fluent-plugin-mongo"]
RUN ["gem", "install", "fluentd-ui"]
COPY conf/fluent.conf /fluentd/etc/

RUN ["fluentd-ui", "setup"]
