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

## Testar a sincronização localmente (spec 013)

Com o compose no ar (`docker compose up -d --build`), crie duas contas e confira que cada uma só vê os
próprios dados. Troque os valores entre `< >`:

```bash
API=http://localhost:8080

# Conta A e conta B (cada cadastro já devolve o token de acesso em dados.tokenAcesso)
curl -s -X POST $API/api/auth/cadastro -H 'Content-Type: application/json' \
  -d '{"nome":"Ana","email":"ana@exemplo.com","senha":"<senha-a>"}'
curl -s -X POST $API/api/auth/cadastro -H 'Content-Type: application/json' \
  -d '{"nome":"Bruno","email":"bruno@exemplo.com","senha":"<senha-b>"}'

# A envia um paciente
curl -s -X POST $API/api/sync/enviar -H "Authorization: Bearer <token-a>" -H 'Content-Type: application/json' \
  -d '{"pacientes":[{"id":"6f1c0a52-8a9e-4a4e-9a51-0f5f3b0b8c11","atualizadoEm":"2026-11-22T14:03:10.120Z",
       "conteudo":{"id":"6f1c0a52-8a9e-4a4e-9a51-0f5f3b0b8c11","nome":"Paciente de teste"}}]}'

# A recebe tudo; B não recebe nada de A
curl -s "$API/api/sync/receber?desde=0" -H "Authorization: Bearer <token-a>"
curl -s "$API/api/sync/receber?desde=0" -H "Authorization: Bearer <token-b>"
```

No app, aponte `EXPO_PUBLIC_API_URL` para `http://<ip-da-maquina>:8080` e siga o quickstart da spec 013
(`specs/013-sincronizar-dados/quickstart.md` no `JumpLab_documentacao`).

A hospedagem em produção (Render) está em [hospedagem/README.md](hospedagem/README.md).
