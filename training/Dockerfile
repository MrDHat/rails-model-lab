FROM ruby:3.4.7-slim
RUN apt-get update -qq && apt-get install -y -qq build-essential && rm -rf /var/lib/apt/lists/*
WORKDIR /training
COPY Gemfile Gemfile.lock ./
RUN bundle install --quiet
