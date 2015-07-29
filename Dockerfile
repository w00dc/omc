#
# test_blog image for development
#

FROM ruby:2.2.0
MAINTAINER Chris Wood "cwood387@gmail.com"

# Install development tools
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# Set up the external share for the Rails app
RUN mkdir -p /app
WORKDIR /app
VOLUME ["/app"]

# Expose the Rails port(s)
EXPOSE 3000

# Set default container command
#ENTRYPOINT bundle exec foreman start

# Start the whole thing up
CMD bundle install && \
    rake db:setup && \
    bundle exec foreman start