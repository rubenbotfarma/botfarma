FROM chatwoot/chatwoot:latest

# Remover e substituir ficheiros modificados
RUN rm -rf /app/app /app/config
COPY app/ /app/app/
COPY config/ /app/config/

WORKDIR /app
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
