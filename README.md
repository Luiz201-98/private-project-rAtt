# RO STARS — Servidor Ragnarok Online (stack completo)

Repositório do projeto **RO STARS**: emulador de MMORPG baseado em **rAthena** (C++), com **API em PHP**, **painel web em React/TypeScript (Vite)** para rankings e arenas **7x7**, e **plugin de cliente** (DLL Win32) para HUD de FPS/ping. Inclui integração com **MySQL/MariaDB**, scripts/NPCs e configurações próprias de servidor.

> **Licença do núcleo rAthena:** GNU GPLv3 — ver [LICENSE](LICENSE) e créditos abaixo.  
> O README genérico de instalação do rAthena foi preservado em [README.rAthena.upstream.md](README.rAthena.upstream.md). Documentação oficial: [Wiki rAthena](https://github.com/rathena/rathena/wiki).

---

## Sumário

- [Visão geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Estrutura de pastas](#estrutura-de-pastas)
- [Stack tecnológica](#stack-tecnológica)
- [Pré-requisitos](#pré-requisitos)
- [Configuração rápida](#configuração-rápida)
- [API PHP (hub / produção)](#api-php-hub--produção)
- [Frontend (`a/`)](#frontend-a)
- [Plugin de cliente (`rostars_hud`)](#plugin-de-cliente-rostars_hud)
- [Banco de dados](#banco-de-dados)
- [Docker (desenvolvimento rAthena)](#docker-desenvolvimento-rathena)
- [Documentação adicional](#documentação-adicional)
- [Créditos e licença](#créditos-e-licença)
- [English summary](#english-summary)

---

## Visão geral

O **RO STARS** é um servidor privado de **Ragnarok Online** com camadas extras além do emulador:

| Camada | Função |
|--------|--------|
| **rAthena** (`src/`, `conf/`, executáveis) | Login, character e map servers; scripts NPC; atcommands; economia e regras do jogo. |
| **API PHP** (`api/`) | Endpoints REST consumidos pelo painel: arenas, guildas, ranking, jogador e partidas (inclui esquema de `match_uid` para IDs únicos entre arenas). |
| **Painel web** (`a/`) | Interface moderna (React + Vite + shadcn/Radix) para visualizar dados do hub. |
| **Cliente** (`client_plugins/rostars_hud`) | DLL opcional: overlay Direct3D 9 com FPS e ping (Win32). |

Fluxo lógico: **jogador → cliente RO → servidores rAthena → MySQL**; **painel → API PHP → MySQL** (mesmo ou schemas relacionados, conforme `config`).

---

## Arquitetura

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────┐
│ Cliente RO  │────▶│ rAthena (C++)    │────▶│ MySQL        │
│ + HUD DLL   │     │ login/char/map   │     │ (ragnarok,   │
└─────────────┘     └──────────────────┘     │  ranking…)   │
                                              └──────┬───────┘
┌─────────────┐     ┌──────────────────┐            │
│ Navegador   │────▶│ API PHP `/api/*` │────────────┘
│ (React SPA) │     └──────────────────┘
└─────────────┘
```

Em produção, o frontend costuma ser servido na **mesma origem** que `/api/*.php` (veja comentários em `api/README.md`).

---

## Estrutura de pastas

| Pasta / arquivo | Descrição |
|-------------------|-----------|
| `src/` | Código-fonte dos servidores rAthena (login, char, map). |
| `conf/` | Configurações (`*.conf`, import SQL flags). |
| `db/` | Scripts e notas de banco relacionadas ao emulador. |
| `sql-files/` | SQL oficiais rAthena (instalação/atualização) — ver [sql-files/README.md](sql-files/README.md). |
| `npc/` | Scripts de NPCs e conteúdo de mundo. |
| `api/` | **API REST PHP** do RO STARS — ver [api/README.md](api/README.md). |
| `a/` | **Frontend** Vite + React + TypeScript (painel / hub). |
| `client_plugins/rostars_hud/` | DLL Win32 HUD (FPS/ping) — ver [client_plugins/rostars_hud/README.md](client_plugins/rostars_hud/README.md). |
| `tools/docker/` | Ambiente Docker para **desenvolvimento** do rAthena (não é receita de produção). |
| `doc/` | Documentação e assets do upstream rAthena. |
| `DESCRICAO_PERFIL.md` | Textos prontos para GitHub/LinkedIn (descrição curta, bio, topics). |

---

## Stack tecnológica

- **Backend do jogo:** C++ (rAthena), compiladores típicos: GCC/Clang (Linux), MSVC (Windows).
- **Banco:** MySQL / MariaDB.
- **API:** PHP (endpoints em `api/*.php`), PDO/MySQLi conforme implementação.
- **Frontend:** Node.js 18+, Vite, React 18, TypeScript, Tailwind, Radix UI / shadcn.
- **Cliente opcional:** C++, Direct3D 9, Visual Studio (Win32).
- **Controle de versão:** Git.

---

## Pré-requisitos

- **Servidor de jogo:** conforme [README.rAthena.upstream.md](README.rAthena.upstream.md) — MySQL/MariaDB, Git, toolchain C++.
- **API + painel:** PHP com extensão MySQL, servidor web (Apache/Nginx) ou PHP embutido para testes; Node.js para `npm install` / `npm run build` em `a/`.
- **Plugin HUD:** Visual Studio 2022 (toolset v143 ou ajuste no `.vcxproj`), plataforma **Win32**.

---

## Configuração rápida

1. **rAthena:** seguir a [wiki oficial de instalação](https://github.com/rathena/rathena/wiki) (Windows/Linux). Ajustar `conf/inter_athena.conf`, `map_athena.conf`, etc., e importar `sql-files` conforme o modo (renewal/pré-renewal).
2. **API:** copiar/ajustar `api/config.local.php`. Variáveis de ambiente suportadas: `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS`, `DB_NAME`, `RATHENA_DB_NAME`, `ARENAS_DB_NAME` — detalhes em [api/README.md](api/README.md).
3. **Frontend:** dentro de `a/`, instalar dependências e build:
   ```bash
   cd a
   npm install
   npm run build
   ```
   Servir a pasta de saída junto com a API na mesma origem em produção (ajuste conforme seu host).
4. **HUD:** compilar `client_plugins/rostars_hud` e injetar a DLL no cliente conforme patch (ex.: Nemo).

> **Segurança:** não commite `config.local.php` com senhas reais; use `config.local.php.example` se criar um template, e `.gitignore` para segredos.

---

## API PHP (hub / produção)

Documentação detalhada: **[api/README.md](api/README.md)**.

Endpoints principais:

| Método | Caminho | Descrição |
|--------|---------|-----------|
| GET | `arenas.php` | Lista de arenas. |
| GET | `guilds.php?arena=toy7` | Guildas (arena opcional). |
| GET | `ranking.php?full=1&expandMatches=1` | Ranking estendido. |
| GET | `player.php?id=123` | Dados de jogador. |
| GET | `match.php?id=<match_uid>` | Partida por ID composto. |

**Match UID:** o hub precisa de um ID numérico único por partida, enquanto cada arena tem seus próprios IDs locais. A API usa:

`match_uid = arenaIndex × 1.000.000.000 + matchId`

---

## Frontend (`a/`)

SPA construída com **Vite + React + TypeScript**, UI com componentes **Radix** / **shadcn**. Scripts úteis:

```bash
cd a
npm run dev      # desenvolvimento
npm run build    # produção
npm run lint     # ESLint
npm run test     # Vitest
```

O build gera assets estáticos para serem servidos ao lado da pasta `api/` em produção.

---

## Plugin de cliente (`rostars_hud`)

DLL **Win32** mínima: FPS e ping no canto da tela, desenho após `EndScene` do **Direct3D 9**. Tecla **HOME** alterna visibilidade; exports para integração de ping RTT — ver [client_plugins/rostars_hud/README.md](client_plugins/rostars_hud/README.md).

Arquivos JSON do **Ragnarok UI Designer** estão em `client_plugins/rostars_hud/designer/` (layouts visuais; integração completa com o EXE do cliente pode exigir passos adicionais).

---

## Banco de dados

- Schema principal do jogo: típico nome `ragnarok` (configurável).
- Tabelas de ranking/arenas podem compartilhar o mesmo schema ou um separado (`DB_NAME=ranking_ros` reservado na API — ver `api/README.md`).
- Importação base rAthena: [sql-files/README.md](sql-files/README.md).

---

## Docker (desenvolvimento rAthena)

A pasta `tools/docker/` oferece ambiente de **desenvolvimento** com container e MySQL. **Não substitui** um guia de produção — ver [tools/docker/README.md](tools/docker/README.md) e a [wiki de instalações](https://github.com/rathena/rathena/wiki/installations).

```bash
cd tools/docker
docker compose up -d
```

---

## Documentação adicional

- **rAthena:** [doc/](doc/) (comandos NPC, atcommands, permissões, etc.).
- **Descrições para perfil:** [DESCRICAO_PERFIL.md](DESCRICAO_PERFIL.md) — textos curtos para GitHub e LinkedIn.
- **README upstream preservado:** [README.rAthena.upstream.md](README.rAthena.upstream.md).

---

## Créditos e licença

- Este repositório inclui **rAthena**, copyright da equipe rAthena, sob **GNU General Public License v3.0** — [LICENSE](LICENSE).
- RO STARS agrega camadas próprias (API, frontend, plugin, configs e scripts). Respeite a licença GPL ao redistribuir binários do emulador e derivados.

---

## English summary

**RO STARS** is a **Ragnarok Online** private server project built on **rAthena** (C++), with a **PHP REST API** for arenas, guilds, rankings and matches (including a composite `match_uid` scheme), a **React + Vite + TypeScript** web hub, and an optional **Win32 Direct3D 9** client DLL for an FPS/ping HUD. Data is stored in **MySQL/MariaDB**. See [api/README.md](api/README.md), [README.rAthena.upstream.md](README.rAthena.upstream.md), and [DESCRICAO_PERFIL.md](DESCRICAO_PERFIL.md) for profile blurbs.

---

**Autor do fork / camadas RO STARS:** Luiz Robério Colares da Silva *(ajuste se colaboradores adicionarem commits significativos).*
