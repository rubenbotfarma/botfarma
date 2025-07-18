FROM ruby:3.4.5
RUN apt-get update && apt-get install -y nodejs npm postgresql-client && npm install -g yarn
COPY . /app
WORKDIR /app
RUN bundle install --without development test
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
