# Como Funciona o Nitro Docker

## Índice
1. [Visão Geral](#visão-geral)
2. [O que é o Just e Como Usá-lo](#o-que-é-o-just-e-como-usá-lo)
3. [Sistema de Submódulos Git](#sistema-de-submódulos-git)
4. [Arquitetura do Projeto](#arquitetura-do-projeto)
5. [Fluxo de Inicialização](#fluxo-de-inicialização)
6. [Configurações Importantes](#configurações-importantes)
7. [Comandos Úteis](#comandos-úteis)

---

## Visão Geral

**Nitro Docker** é um ambiente de desenvolvimento completo baseado em Docker para executar um servidor privado de Habbo Hotel. O projeto combina:

- **Arcturus Emulator** (versão 3.0.X a 3.5.0): Emulador do servidor Habbo em Java
- **Nitro React**: Cliente web moderno construído com React
- **MySQL/MariaDB**: Banco de dados para armazenar todos os dados do servidor
- **Sistema de Assets**: Ferramentas para converter arquivos SWF em assets compatíveis com Nitro

O projeto foi projetado para funcionar em múltiplas plataformas (Windows, Linux, macOS) e fornecer um ambiente completo com configuração mínima.

---

## O que é o Just e Como Usá-lo

### O que é Just?

**Just** é um executor de comandos (similar ao Make, mas mais simples) que fornece atalhos convenientes para operações Docker. Pense nele como um conjunto de scripts predefinidos que facilitam a vida do desenvolvedor.

### Instalando o Just

```bash
# Linux/macOS (com Homebrew)
brew install just

# Linux (via cargo)
cargo install just

# Arch Linux
pacman -S just
```

### Principais Comandos do Justfile

O arquivo `justfile` na raiz do projeto contém mais de 20 comandos organizados em categorias:

#### Instalação e Configuração Inicial

```bash
# Inicializa e atualiza todos os submódulos Git
just install

# Inicia todos os containers (MySQL, Arcturus, Nitro)
just start-all

# Remove todos os containers, imagens e volumes
just clean-docker
```

#### Gerenciamento do Arcturus Emulator

```bash
# Reinicia o emulador
just restart-arcturus

# Para o emulador
just stop-arcturus

# Inicia o emulador
just start-arcturus

# Recompila o emulador Java do zero
just recompile-arcturus

# Monitora os logs em tempo real
just watch-arcturus

# Abre shell bash no container
just shell-arcturus

# Abre console MySQL
just mysql
```

#### Desenvolvimento do Nitro Client

```bash
# Reinicia o servidor de desenvolvimento
just restart-nitro

# Para o servidor
just stop-nitro

# Inicia o servidor
just start-nitro

# Monitora logs do Nitro
just watch-nitro

# Abre shell bash no container
just shell-nitro

# Extrai e converte assets SWF para formato Nitro
just extract-nitro-assets
```

### Como o Just Funciona Internamente

Quando você executa `just start-all`, por exemplo, o Just executa uma sequência de comandos Docker:

```bash
docker compose down    # Para containers existentes
docker compose up --build -d    # Reconstrói e inicia em background
```

É basicamente um wrapper amigável para comandos Docker Compose complexos que você não quer digitar repetidamente.

---

## Sistema de Submódulos Git

### O que são Submódulos Git?

Submódulos Git permitem que você mantenha um repositório Git como um subdiretório de outro repositório Git. Isso é útil quando você quer incluir bibliotecas ou projetos externos sem copiar todo o código.

### Como o Nitro Docker Usa Submódulos

O projeto baixa código de **6 repositórios externos** usando submódulos Git, definidos no arquivo `.gitmodules`:

#### 1. **Arcturus Emulator** (`emulator/arcturus`)
```
URL: https://git.krews.org/morningstar/Arcturus-Community.git
Propósito: Código-fonte do emulador Habbo em Java
```

#### 2. **NitroWebSocket Plugin** (`emulator/nitrowebsockets`)
```
URL: https://git.krews.org/morningstar/nitrowebsockets-for-ms.git
Propósito: Plugin de WebSocket para comunicação entre Nitro e Arcturus
```

#### 3. **Nitro React** (`nitro/nitro-react`)
```
URL: https://github.com/billsonnn/nitro-react.git
Propósito: Cliente Habbo moderno baseado em React
```

#### 4. **Nitro Converter** (`nitro/nitro-converter`)
```
URL: https://github.com/billsonnn/nitro-converter.git
Propósito: Converte arquivos SWF para formato Nitro
```

#### 5. **Nitro SWF** (`nitro/nitro-swf`)
```
URL: https://git.krews.org/morningstar/arcturus-morningstar-default-swf-pack.git
Propósito: Pack de arquivos SWF padrão do Morningstar
```

#### 6. **Nitro Assets** (`nitro/nitro-assets`)
```
URL: https://git.krews.org/nitro/default-assets.git
Propósito: Armazena assets convertidos (conteúdo ignorado pelo .gitignore)
```

### Como os Submódulos são Baixados

Quando você executa `just install`, o comando faz:

```bash
git submodule init      # Inicializa os submódulos
git submodule update    # Baixa o conteúdo dos submódulos
```

Isso clona todos os 6 repositórios externos para suas respectivas pastas.

### Compilação do Plugin WebSocket

O plugin **NitroWebSocket** agora é compilado localmente durante o build do emulador. O script de build (`emulator/scripts/build.sh`) executa:

```bash
# Compilar emulador Arcturus
cd /app/arcturus
mvn package

# Compilar plugin NitroWebSocket
cd /app/nitrowebsockets
mvn package

# Copiar plugin para pasta de plugins
cp /app/nitrowebsockets/target/NitroWebsockets-*.jar /app/arcturus/target/plugins/
```

Este plugin é essencial para a comunicação WebSocket entre o cliente Nitro e o emulador Arcturus. Por estar incluído como submódulo, você pode modificar o código-fonte do plugin e recompilá-lo conforme necessário.

---

## Arquitetura do Projeto

### Estrutura de Diretórios

```
nitro-docker/
├── emulator/                    # Container do Arcturus Emulator
│   ├── arcturus/               # [SUBMÓDULO] Código-fonte do emulador
│   ├── nitrowebsockets/        # [SUBMÓDULO] Código-fonte do plugin WebSocket
│   ├── config.ini              # Configuração do emulador
│   ├── Dockerfile              # Imagem Docker (Java 8 Alpine + Maven)
│   ├── scripts/build.sh        # Compila emulador e plugin
│   └── supervisor/             # Configuração do Supervisord
│
├── nitro/                      # Container do Cliente Nitro
│   ├── nitro-react/           # [SUBMÓDULO] Cliente React
│   ├── nitro-converter/       # [SUBMÓDULO] Conversor SWF→Nitro
│   ├── nitro-swf/            # [SUBMÓDULO] Pack de arquivos SWF
│   ├── nitro-assets/         # [SUBMÓDULO] Assets convertidos
│   ├── configuration/         # Arquivos de configuração
│   │   ├── nitro-react/public/
│   │   │   ├── renderer-config.json    # URLs de assets, WebSocket
│   │   │   └── ui-config.json          # Configurações da interface
│   │   └── nitro-converter/
│   │       └── configuration.json      # Configurações do conversor
│   ├── Dockerfile             # Imagem Docker (Node 20 Alpine)
│   ├── scripts/build.sh       # Instala dependências e inicia 3 servidores
│   └── supervisor/            # Gerencia 3 processos simultaneamente
│
├── mysql/                     # Container MySQL
│   ├── conf.d/my.cnf         # Configuração do MySQL
│   └── dumps/                 # Scripts de inicialização do banco
│       ├── arcturus_3.0.0-stable_base_database--compact.sql
│       └── arcturus_migration_3.0.0_to_3.5.0.sql
│
├── docker-compose.yaml        # Orquestra os 3 serviços
├── justfile                   # Definições de comandos Just
└── .gitmodules               # Configuração dos submódulos Git
```

### Três Containers Docker

#### A. **MySQL Service** (Porta 13306)
- **Imagem**: `mariadb:10.6`
- **Credenciais**:
  - Usuário: `arcturus_user`
  - Senha: `arcturus_pw`
  - Database: `arcturus`
- **Função**: Armazena dados de usuários, quartos, mobília, conquistas
- **Inicialização**: Executa dumps SQL automaticamente na primeira execução

#### B. **Arcturus Service** (Portas 3000, 3001, 2096)
- **Imagem Base**: `eclipse-temurin:8-jdk-alpine`
- **Processo de Build**:
  1. Instala OpenJDK 8, Maven, cliente MySQL, Supervisord
  2. Executa `build.sh` que:
     - Compila o emulador Arcturus com Maven
     - Compila o plugin NitroWebSocket com Maven
     - Copia o plugin para a pasta de plugins do emulador
  3. Inicia emulador via Supervisord
- **Portas Expostas**:
  - `3000`: Servidor de jogo
  - `3001`: RCON (controle remoto)
  - `2096`: WebSocket
- **Volumes Persistentes**:
  - `volume-arcturus-maven-repo`: Cache de dependências Maven
  - `volume-arcturus-target`: Artefatos compilados

#### C. **Nitro Service** (Portas 1080, 8080, 8081)
- **Imagem Base**: `node:20.2.0-alpine3.18`
- **Processo de Build**:
  1. Instala Node.js, http-server, rsync
  2. Executa `build.sh` que instala dependências
  3. Inicia 3 processos via Supervisord:
     - **Servidor de Assets**: Porta 8080 (serve `/nitro-assets`)
     - **Servidor SWF**: Porta 8081 (serve `/nitro-swf`)
     - **Dev Server Nitro**: Porta 5154 (Vite dev server)
- **Portas Expostas**:
  - `1080`: Aplicação Nitro React (porta principal)
  - `8080`: Servidor de assets
  - `8081`: Servidor de SWF
- **Volumes Persistentes**:
  - `volume-nitro-converter-node-modules`: Dependências do conversor
  - `volume-nitro-react-node-modules`: Dependências do React

### Diagrama de Fluxo

```
┌─────────────────────────────────────────────────────────┐
│                    Navegador do Usuário                  │
│            http://127.0.0.1:1080?sso=123                │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│               Container Nitro (Node.js)                  │
│  ┌────────────────────────────────────────────────┐    │
│  │  Nitro React (Porta 5154)                      │    │
│  │  - Vite Dev Server                             │    │
│  └────────────────────────────────────────────────┘    │
│  ┌────────────────────────────────────────────────┐    │
│  │  Servidor Assets (Porta 8080)                  │    │
│  │  - Serve arquivos .nitro                       │    │
│  └────────────────────────────────────────────────┘    │
│  ┌────────────────────────────────────────────────┐    │
│  │  Servidor SWF (Porta 8081)                     │    │
│  │  - Serve arquivos .swf para conversão          │    │
│  └────────────────────────────────────────────────┘    │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ WebSocket (ws://127.0.0.1:2096)
                     ▼
┌─────────────────────────────────────────────────────────┐
│            Container Arcturus (Java 8)                   │
│  ┌────────────────────────────────────────────────┐    │
│  │  Arcturus Emulator                             │    │
│  │  - Porta 3000: Servidor de jogo                │    │
│  │  - Porta 3001: RCON                            │    │
│  │  - Porta 2096: WebSocket (plugin)              │    │
│  └────────────────────────────────────────────────┘    │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ MySQL Protocol (3306)
                     ▼
┌─────────────────────────────────────────────────────────┐
│             Container MySQL (MariaDB 10.6)               │
│  ┌────────────────────────────────────────────────┐    │
│  │  Database: arcturus                            │    │
│  │  - Tabelas de usuários, quartos, mobília      │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

---

## Fluxo de Inicialização

### 1. Primeira Configuração

```bash
# Passo 1: Clone o repositório
git clone https://github.com/seu-usuario/nitro-docker.git
cd nitro-docker

# Passo 2: Baixe todos os submódulos
just install
# Isso executa: git submodule init && git submodule update
# Baixa: arcturus, nitrowebsockets, nitro-react, nitro-converter, nitro-swf, nitro-assets

# Passo 3: Inicie todos os containers
just start-all
# Isso executa: docker compose down && docker compose up --build -d
```

### 2. O que Acontece Durante `just start-all`

#### Ordem de Inicialização:

1. **MySQL inicia primeiro**
   - Container `mysql-nitro` sobe
   - MariaDB 10.6 inicia
   - Scripts SQL em `/mysql/dumps/` são executados automaticamente
   - Database `arcturus` é criado e populado

2. **Arcturus aguarda MySQL estar pronto**
   - Container `arcturus-nitro` inicia build
   - Dockerfile copia código dos submódulos `arcturus/` e `nitrowebsockets/`
   - Script `build.sh` executa:
     ```bash
     cd /app/arcturus
     mvn package                  # Compila o emulador

     cd /app/nitrowebsockets
     mvn package                  # Compila o plugin WebSocket

     # Copia plugin para pasta de plugins
     cp /app/nitrowebsockets/target/NitroWebsockets-*.jar /app/arcturus/target/plugins/
     ```
   - Emulador se conecta ao MySQL
   - Inicia escutando nas portas 3000, 3001, 2096

3. **Nitro inicia por último**
   - Container `nitro-docker` inicia build
   - Dockerfile copia submódulos `nitro-react/` e `nitro-converter/`
   - Script `build.sh` executa:
     ```bash
     cd nitro-converter && npm install
     cd nitro-react && npm install
     ```
   - Supervisord inicia 3 processos simultaneamente:
     - `http-server nitro-assets -p 8080`
     - `http-server nitro-swf -p 8081`
     - `cd nitro-react && npm run dev -- --host 0.0.0.0 --port 5154`

### 3. Acesso ao Sistema

Após todos os containers iniciarem (pode levar 2-5 minutos):

1. Abra o navegador em: `http://127.0.0.1:1080?sso=123`
   - SSO `123` é o ticket de login padrão configurado no banco
2. O cliente Nitro carrega
3. Conecta ao emulador via WebSocket (`ws://127.0.0.1:2096`)
4. Assets são carregados de `http://127.0.0.1:8080`

---

## Configurações Importantes

### Configuração do Emulador (`emulator/config.ini`)

```ini
[database]
db.hostname=mysql-nitro
db.port=3306
db.username=arcturus_user
db.password=arcturus_pw
db.database=arcturus

[game]
game.host=0.0.0.0
game.port=3000

[websockets]
websockets.whitelist=*
ws.nitro.host=0.0.0.0
ws.nitro.port=2096
```

**Importante**: `db.hostname=mysql-nitro` usa o nome do serviço Docker, não `localhost`.

### Configuração do Nitro Renderer (`nitro/configuration/nitro-react/public/renderer-config.json`)

```json
{
  "socket.url": "ws://127.0.0.1:2096",
  "asset.url": "http://127.0.0.1:8080/assets",
  "image.library.url": "http://127.0.0.1:8080/images",
  "furnidata.load.url": "http://127.0.0.1:8080/%gamedata%/FurnitureData.json"
}
```

### Configuração da UI (`nitro/configuration/nitro-react/public/ui-config.json`)

Contém configurações da interface como:
- Configurações de câmera
- Sistema de conquistas
- Configurações de quarto
- Configurações de avatar

### Configuração do Conversor (`nitro/configuration/nitro-converter/configuration.json`)

Define como arquivos SWF são convertidos para o formato `.nitro`:

```json
{
  "output.folder": "../nitro-assets",
  "swf.url": "http://localhost:8081"
}
```

---

## Comandos Úteis

### Desenvolvimento Diário

```bash
# Iniciar ambiente
just start-all

# Ver logs em tempo real
just watch-arcturus    # Logs do emulador
just watch-nitro       # Logs do cliente

# Reiniciar após mudanças
just restart-arcturus  # Reinicia emulador
just restart-nitro     # Reinicia cliente
```

### Conversão de Assets

```bash
# Converter SWF para formato Nitro
just extract-nitro-assets

# Isso executa dentro do container:
# cd nitro-converter && npm start
```

### Acesso Direto aos Containers

```bash
# Abrir shell no container do emulador
just shell-arcturus

# Abrir shell no container do Nitro
just shell-nitro

# Acessar MySQL
just mysql
# Usuário: arcturus_user
# Senha: arcturus_pw
```

### Recompilação Completa

```bash
# Recompilar emulador do zero
just recompile-arcturus

# Limpar tudo e recomeçar
just clean-docker    # Remove containers, volumes, imagens
just install         # Atualiza submódulos
just start-all       # Reinicia tudo
```

### Comandos Docker Diretos

```bash
# Ver status dos containers
docker compose ps

# Ver logs de um serviço específico
docker compose logs -f mysql-nitro
docker compose logs -f arcturus-nitro
docker compose logs -f nitro-docker

# Parar tudo
docker compose down

# Parar e remover volumes (CUIDADO: apaga o banco de dados)
docker compose down -v
```

---

## Resolução de Problemas

### Assets não carregam
```bash
# Verifique se os servidores de assets estão rodando
docker compose logs nitro-docker

# Tente extrair os assets novamente
just extract-nitro-assets
```

### Emulador não conecta ao MySQL
```bash
# Verifique se o MySQL está rodando
docker compose ps mysql-nitro

# Veja os logs do MySQL
docker compose logs mysql-nitro

# Verifique as credenciais em emulator/config.ini
```

### Mudanças no código não aparecem
```bash
# Reinicie o container específico
just restart-nitro      # Para mudanças no cliente
just restart-arcturus   # Para mudanças no emulador

# Ou reconstrua tudo
just start-all
```

### Submódulos desatualizados
```bash
# Atualizar todos os submódulos para a versão mais recente
git submodule update --remote

# Ou apenas um específico
cd nitro/nitro-react
git pull origin master
```

---

## Resumo do Fluxo Completo

1. **Instalação**: `just install` baixa 6 repositórios via submódulos Git
2. **Build**: `just start-all` compila:
   - Emulador Arcturus (Java)
   - Plugin NitroWebSocket (Java)
   - Dependências do Nitro (Node.js)
3. **Inicialização**: 3 containers sobem (MySQL → Arcturus → Nitro)
4. **Desenvolvimento**: Use comandos `just` para reiniciar, ver logs, recompilar
5. **Conversão de Assets**: `just extract-nitro-assets` converte SWF → Nitro
6. **Acesso**: Navegador em `http://127.0.0.1:1080?sso=123`

O sistema Just simplifica toda a complexidade do Docker Compose, tornando o desenvolvimento muito mais ágil e acessível.

## Modificando o Plugin WebSocket

Agora que o plugin WebSocket está incluído como submódulo, você pode:

1. **Editar o código-fonte**:
   ```bash
   cd emulator/nitrowebsockets
   # Edite os arquivos Java conforme necessário
   ```

2. **Recompilar o plugin**:
   ```bash
   just recompile-arcturus
   # Isso recompila tanto o emulador quanto o plugin
   ```

3. **Testar as mudanças**:
   ```bash
   just restart-arcturus
   # O emulador reinicia com o plugin atualizado
   ```
