# Guia: Adicionar Plugin WebSocket como Submódulo

Este guia ensina como adicionar o plugin NitroWebSocket como submódulo Git manualmente, sem usar o `just`. Útil para forks ou instalações personalizadas.

---

## Pré-requisitos

- Git instalado
- Acesso ao repositório do projeto
- Acesso à internet para clonar o submódulo

---

## Passo 1: Adicionar o Submódulo Git

No diretório raiz do projeto, execute:

```bash
git submodule add https://git.krews.org/morningstar/nitrowebsockets-for-ms.git emulator/nitrowebsockets
```

**O que esse comando faz:**
- Clona o repositório do plugin para `emulator/nitrowebsockets/`
- Adiciona entrada no arquivo `.gitmodules`
- Cria referência no Git do projeto principal

**Saída esperada:**
```
Cloning into '/caminho/para/seu/projeto/emulator/nitrowebsockets'...
remote: Enumerating objects: ...
remote: Counting objects: ...
remote: Compressing objects: ...
Receiving objects: 100% ...
```

---

## Passo 2: Verificar se o Submódulo foi Adicionado

```bash
# Verificar arquivo .gitmodules
cat .gitmodules

# Verificar se a pasta existe
ls -la emulator/nitrowebsockets/

# Verificar status do Git
git status
```

**Você deve ver:**
- Arquivo `.gitmodules` modificado ou criado
- Pasta `emulator/nitrowebsockets/` com conteúdo clonado
- Git mostrando arquivos novos para commit

---

## Passo 3: Modificar o Script de Build

Edite o arquivo `emulator/scripts/build.sh`:

### Antes (versão original):
```bash
#!/bin/bash

supervisord -c /app/supervisor/supervisord.conf

cd /app/arcturus
mvn package
cp /app/config.ini /app/arcturus/target/config.ini
mkdir /app/arcturus/target/plugins
cd /app/arcturus/target/plugins
wget https://git.krews.org/morningstar/nitrowebsockets-for-ms/-/raw/aff34551b54527199401b343a35f16076d1befd5/target/NitroWebsockets-3.1.jar

supervisorctl start arcturus-emulator

tail -f /dev/null
```

### Depois (com compilação local):
```bash
#!/bin/bash

supervisord -c /app/supervisor/supervisord.conf

cd /app/arcturus
mvn package
cp /app/config.ini /app/arcturus/target/config.ini

# Compilar plugin NitroWebSocket localmente
cd /app/nitrowebsockets
mvn package

# Copiar plugin compilado para pasta de plugins do emulador
mkdir -p /app/arcturus/target/plugins
cp /app/nitrowebsockets/target/NitroWebsockets-*.jar /app/arcturus/target/plugins/

supervisorctl start arcturus-emulator

tail -f /dev/null
```

**Mudanças principais:**
1. Remove a linha `wget` que baixava o `.jar` compilado
2. Adiciona compilação Maven do plugin
3. Copia o `.jar` compilado localmente para a pasta de plugins
4. Usa `mkdir -p` para criar a pasta caso não exista

---

## Passo 4: Commit das Mudanças

```bash
# Adicionar os arquivos modificados
git add .gitmodules
git add emulator/nitrowebsockets
git add emulator/scripts/build.sh

# Fazer commit
git commit -m "Adicionar plugin NitroWebSocket como submódulo

- Adiciona submódulo nitrowebsockets-for-ms em emulator/nitrowebsockets
- Modifica build.sh para compilar plugin localmente
- Remove download via wget do plugin compilado"

# (Opcional) Fazer push
git push origin main
```

---

## Passo 5: Testar a Compilação

### Se você usa Docker Compose:

```bash
# Parar containers existentes
docker compose down

# Reconstruir e iniciar
docker compose up --build -d

# Verificar logs do build
docker compose logs -f arcturus
```

### Se você NÃO usa Docker:

```bash
# Entrar na pasta do plugin
cd emulator/nitrowebsockets

# Compilar o plugin
mvn clean package

# Verificar se o .jar foi criado
ls -la target/NitroWebsockets-*.jar

# Copiar para pasta de plugins do Arcturus
cp target/NitroWebsockets-*.jar ../arcturus/target/plugins/
```

---

## Passo 6: Verificar se o Plugin está Funcionando

1. **Verificar se o `.jar` existe:**
   ```bash
   # Se usando Docker
   docker exec -it arcturus ls -la /app/arcturus/target/plugins/

   # Se local
   ls -la emulator/arcturus/target/plugins/
   ```

2. **Verificar logs do emulador:**
   ```bash
   # Se usando Docker
   docker compose logs arcturus | grep -i websocket

   # Você deve ver algo como:
   # [INFO] Loading plugin: NitroWebsockets
   # [INFO] NitroWebsockets enabled
   ```

3. **Testar conexão WebSocket:**
   - Acesse o cliente Nitro em `http://127.0.0.1:1080?sso=123`
   - Verifique o console do navegador (F12)
   - Deve conectar em `ws://127.0.0.1:2096`

---

## Trabalhando em Outro Computador / Fork

Se você ou outra pessoa clonar o repositório depois dessas mudanças:

### Primeira vez (clone completo):
```bash
# Clonar o repositório principal
git clone https://seu-fork.git
cd seu-projeto

# Inicializar e baixar TODOS os submódulos
git submodule init
git submodule update

# Ou fazer tudo de uma vez:
git clone --recurse-submodules https://seu-fork.git
```

### Atualizar submódulos existentes:
```bash
# Atualizar todos os submódulos para a versão mais recente
git submodule update --remote

# Ou atualizar apenas o plugin WebSocket
cd emulator/nitrowebsockets
git pull origin master
cd ../..
```

---

## Modificando o Código do Plugin

Agora que você tem o código-fonte:

### 1. Editar o código
```bash
cd emulator/nitrowebsockets/src/main/java/
# Edite os arquivos Java conforme necessário
```

### 2. Recompilar
```bash
cd emulator/nitrowebsockets
mvn clean package
```

### 3. Testar
```bash
# Se usando Docker
docker compose restart arcturus

# Se local
# Copie o novo .jar e reinicie o emulador manualmente
```

### 4. (Opcional) Contribuir de volta
Se você fez melhorias no plugin:
```bash
cd emulator/nitrowebsockets
git checkout -b minha-feature
git add .
git commit -m "Adiciona nova funcionalidade X"
git push origin minha-feature
# Depois crie um Pull Request no repositório original
```

---

## Comandos Úteis para Gerenciar Submódulos

```bash
# Ver status de todos os submódulos
git submodule status

# Ver diferenças nos submódulos
git diff --submodule

# Atualizar submódulo específico
git submodule update --remote emulator/nitrowebsockets

# Remover um submódulo (se necessário)
git submodule deinit emulator/nitrowebsockets
git rm emulator/nitrowebsockets
rm -rf .git/modules/emulator/nitrowebsockets
```

---

## Estrutura Final

Depois de seguir todos os passos, você terá:

```
seu-projeto/
├── .gitmodules                  # Configuração dos submódulos
├── emulator/
│   ├── arcturus/               # Submódulo do emulador
│   ├── nitrowebsockets/        # ✅ Submódulo do plugin WebSocket
│   │   ├── src/               # Código-fonte Java
│   │   ├── pom.xml            # Configuração Maven
│   │   ├── target/            # Binários compilados
│   │   │   └── NitroWebsockets-*.jar
│   │   └── README.md
│   ├── scripts/
│   │   └── build.sh           # ✅ Modificado para compilar plugin
│   └── config.ini
└── ...
```

---

## Resumo dos Comandos Principais

```bash
# 1. Adicionar submódulo
git submodule add https://git.krews.org/morningstar/nitrowebsockets-for-ms.git emulator/nitrowebsockets

# 2. Editar emulator/scripts/build.sh (manual)

# 3. Commit
git add .gitmodules emulator/nitrowebsockets emulator/scripts/build.sh
git commit -m "Adicionar plugin NitroWebSocket como submódulo"

# 4. Testar
docker compose up --build -d

# Em outro computador/fork:
git clone --recurse-submodules https://seu-repo.git
```

---

## Troubleshooting

### Erro: "Submódulo vazio após clone"
```bash
# Solução:
git submodule init
git submodule update
```

### Erro: "Plugin não compila"
```bash
# Verificar se Maven está instalado no container
docker exec -it arcturus mvn --version

# Ver logs de compilação
docker compose logs arcturus
```

### Erro: "Plugin não carrega no emulador"
```bash
# Verificar se o .jar existe
docker exec -it arcturus ls -la /app/arcturus/target/plugins/

# Verificar permissões
docker exec -it arcturus chmod +r /app/arcturus/target/plugins/*.jar
```

### Submódulo desatualizado
```bash
# Atualizar para a versão mais recente
cd emulator/nitrowebsockets
git fetch
git pull origin master
cd ../..
git add emulator/nitrowebsockets
git commit -m "Atualizar plugin WebSocket"
```

---

## Vantagens de Usar Submódulo

✅ **Código-fonte disponível** - Você pode modificar o plugin
✅ **Controle de versão** - Sabe exatamente qual versão do plugin está usando
✅ **Compilação local** - Não depende de binários pré-compilados externos
✅ **Desenvolvimento** - Facilita debug e desenvolvimento de features
✅ **Contribuição** - Pode contribuir melhorias de volta ao projeto original

---

## Referências

- **Repositório do Plugin**: https://git.krews.org/morningstar/nitrowebsockets-for-ms
- **Documentação Git Submodules**: https://git-scm.com/book/en/v2/Git-Tools-Submodules
- **Arcturus Community**: https://git.krews.org/morningstar/Arcturus-Community
