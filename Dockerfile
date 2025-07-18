FROM chatwoot/chatwoot:latest
COPY . /app/
WORKDIR /app
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
