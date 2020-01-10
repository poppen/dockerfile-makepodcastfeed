FROM ruby:2.7.0-alpine3.11

COPY makerss.rb /
RUN chmod +x /makerss.rb \
    && gem install -N rss
