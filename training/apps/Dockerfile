FROM ruby:3.4.7-slim
RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends build-essential git ca-certificates iproute2 libyaml-dev \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
# The apps share one Gemfile.lock (check-app-tasks.sh checks), so one image serves them all.
COPY toolshed/Gemfile toolshed/Gemfile.lock /opt/toolshed/
RUN cd /opt/toolshed && bundle install --quiet
