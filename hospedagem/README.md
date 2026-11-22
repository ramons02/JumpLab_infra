# Hospedagem no Render (spec 013, FR-020)

A API (`JumpLab_api`, Java com Spring Boot) e o banco PostgreSQL ficam no [Render](https://render.com).
A Vercel não é usada: o app é Android e não há site (D17).

Este documento descreve a configuração. Nenhum valor real (senha, segredo, conexão) entra no Git: os
valores são preenchidos só no painel do Render (princípio VI, decisão D7).

## Banco: PostgreSQL do Render

1. Criar um **PostgreSQL** no Render, na mesma região do serviço da API.
2. Anotar, no próprio painel, a *Internal Database URL*, o usuário e a senha. Esses valores vão para as
   variáveis da API (abaixo) e para nenhum outro lugar.
3. As tabelas não são criadas à mão: o Flyway da API roda as migrações (`V12_1`, `V13_1`...) na subida.

## API: serviço web a partir do Dockerfile

1. Criar um **Web Service** ligado ao repositório `JumpLab_api`, com *Runtime* **Docker**: o Render usa o
   `Dockerfile` da raiz (multi-stage, criado na spec 012), que compila e roda a API na porta 8080.
2. Em *Environment*, cadastrar as variáveis abaixo (só os nomes estão aqui; os valores, só no painel).
3. O Render entrega a API em HTTPS (`https://<nome-do-servico>.onrender.com`). Essa é a URL de produção
   do app.
4. *Health check*: o próprio Render confere a porta; a subida falha se o Flyway não conseguir migrar ou
   se `JUMPLAB_JWT_SEGREDO` faltar (a API não sobe sem segredo).

### Variáveis da API

| Variável | Descrição |
|---|---|
| `SPRING_DATASOURCE_URL` | URL JDBC do PostgreSQL do Render (`jdbc:postgresql://<host-interno>:5432/<banco>`) |
| `SPRING_DATASOURCE_USERNAME` | usuário do banco do Render |
| `SPRING_DATASOURCE_PASSWORD` | senha do banco do Render |
| `JUMPLAB_JWT_SEGREDO` | segredo que assina os tokens (pelo menos 32 bytes; `openssl rand -base64 48`), diferente do local |
| `JUMPLAB_JWT_ACESSO_MINUTOS` | validade do token de acesso, em minutos (15) |
| `JUMPLAB_JWT_RENOVACAO_DIAS` | validade do token de renovação, em dias (30) |

As mesmas variáveis, com descrição e sem valor, estão no `.env.example` desta pasta.

## App: URL de produção

No `JumpLab_app`, a variável `EXPO_PUBLIC_API_URL` recebe a URL HTTPS do serviço do Render no build de
produção (o `.env.example` do app descreve a variável, sem o valor). Em build de produção o app recusa
endereço sem `https://` (spec 012).
