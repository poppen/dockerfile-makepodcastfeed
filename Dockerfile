FROM ruby:2.7.0-alpine3.11

COPY makerss.rb /usr/local/bin
RUN chmod +x /usr/local/bin/makerss.rb
