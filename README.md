# JumpLab_infra

Containers e configuração para subir a API do JumpLab com o PostgreSQL. Regras do projeto na constituição
do [JumpLab_documentacao](https://github.com/ramons02/JumpLab_documentacao)
(`.specify/memory/constitution.md`).

Este repositório guarda só a configuração e os **nomes** das variáveis. Nenhum valor real de senha,
segredo ou conexão entra no Git (princípio VI, decisão D7).

## Pré-requisitos

- Docker com o Docker Compose.
- O `JumpLab_api` clonado ao lado desta pasta (`../JumpLab_api`): o compose constrói a imagem a partir dele.

## Subir localmente

```bash
cp .env.example .env
# Preencha o .env. Para o segredo do JWT (pelo menos 32 bytes):
openssl rand -base64 48

docker compose up -d --build     # sobe o PostgreSQL e a API (porta 8080)
docker compose logs -f api       # acompanha a API; o Flyway cria as tabelas na subida
docker compose down              # para tudo (os dados ficam no volume dados-postgres)
docker compose down -v           # para e apaga os dados do banco local
```

Verificação do repositório: `docker compose config` sem erros.

O `.env` está no `.gitignore` e nunca vai para o Git. Se um segredo for commitado por engano, troque-o
imediatamente: apagar do histórico não basta.
