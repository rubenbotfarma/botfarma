FROM chatwoot/chatwoot:latest

# Copiar código personalizado
COPY . /app/

# Definir diretório de trabalho  
WORKDIR /app

# Instalar dependências se necessário
RUN bundle install --without development test

# Expor porta
EXPOSE 3000

# Comando padrão
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]FROM chatwoot/chatwoot:latest

# Copiar suas alterações
COPY . /app/

# Definir diretório de trabalho
WORKDIR /app

# Instalar dependências (se necessário)
RUN bundle install

# Comando padrão
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]FROM chatwoot/chatwoot:latest

# Remover e substituir ficheiros modificados
RUN rm -rf /app/app /app/config
COPY app/ /app/app/
COPY config/ /app/config/

WORKDIR /app
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
