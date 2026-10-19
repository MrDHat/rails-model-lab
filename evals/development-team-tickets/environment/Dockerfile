FROM ruby:3.4.7-slim@sha256:93dd13e28987e373857fbda4a7f4ae99e9f7acb6fcc266035e551229974d1c89
WORKDIR /app
RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential git libyaml-dev pkg-config iproute2 && rm -rf /var/lib/apt/lists/*
COPY app/Gemfile* ./
RUN bundle install
COPY app/ ./
RUN chmod +x bin/rails && bin/rails db:prepare && bin/rails test
RUN git init -q && git add -A && git -c user.name=eval -c user.email=eval@localhost commit -qm "Independent team tickets starter"
