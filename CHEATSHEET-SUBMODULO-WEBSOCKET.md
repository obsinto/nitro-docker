# Cheat Sheet: Adicionar WebSocket como Submódulo

## 🚀 Instalação Rápida

```bash
# 1. Adicionar submódulo
git submodule add https://git.krews.org/morningstar/nitrowebsockets-for-ms.git emulator/nitrowebsockets

# 2. Editar emulator/scripts/build.sh (veja abaixo)

# 3. Commit
git add .gitmodules emulator/nitrowebsockets emulator/scripts/build.sh
git commit -m "Add NitroWebSocket as submodule"

# 4. Build
docker compose up --build -d
```

---

## 📝 Edição do build.sh

**Substituir estas linhas:**
```bash
mkdir /app/arcturus/target/plugins
cd /app/arcturus/target/plugins
wget https://git.krews.org/.../NitroWebsockets-3.1.jar
```

**Por estas:**
```bash
# Compilar plugin NitroWebSocket localmente
cd /app/nitrowebsockets
mvn package

# Copiar plugin compilado para pasta de plugins
mkdir -p /app/arcturus/target/plugins
cp /app/nitrowebsockets/target/NitroWebsockets-*.jar /app/arcturus/target/plugins/
```

---

## 🔄 Clone em Outro Local

```bash
# Clone com todos os submódulos de uma vez
git clone --recurse-submodules https://seu-repo.git

# OU clone normal + inicializar submódulos depois
git clone https://seu-repo.git
cd seu-repo
git submodule init
git submodule update
```

---

## 🛠️ Comandos Úteis

```bash
# Ver status dos submódulos
git submodule status

# Atualizar submódulo para última versão
git submodule update --remote emulator/nitrowebsockets

# Atualizar TODOS os submódulos
git submodule update --remote

# Compilar plugin manualmente
cd emulator/nitrowebsockets && mvn clean package

# Verificar se plugin foi compilado
ls -la emulator/nitrowebsockets/target/NitroWebsockets-*.jar
```

---

## ✏️ Modificar o Plugin

```bash
# 1. Editar código
cd emulator/nitrowebsockets/src/main/java/
# ... faça suas modificações ...

# 2. Recompilar
cd ../../
mvn clean package

# 3. Reiniciar emulador
docker compose restart arcturus

# 4. Ver logs
docker compose logs -f arcturus
```

---

## 📦 Estrutura Final

```
projeto/
├── .gitmodules                          # ✅ Atualizado
├── emulator/
│   ├── arcturus/                       # Submódulo
│   ├── nitrowebsockets/                # ✅ NOVO - Submódulo do plugin
│   │   ├── src/                        # Código-fonte
│   │   ├── pom.xml
│   │   └── target/
│   │       └── NitroWebsockets-*.jar
│   ├── scripts/
│   │   └── build.sh                    # ✅ Modificado
│   └── config.ini
└── ...
```

---

## ⚠️ Troubleshooting Rápido

| Problema | Solução |
|----------|---------|
| Submódulo vazio | `git submodule init && git submodule update` |
| Plugin não compila | `docker exec -it arcturus mvn --version` |
| Plugin não carrega | `docker exec -it arcturus ls /app/arcturus/target/plugins/` |
| Versão desatualizada | `cd emulator/nitrowebsockets && git pull` |

---

## 🎯 Verificação Rápida

```bash
# ✅ Submódulo existe?
ls emulator/nitrowebsockets/pom.xml

# ✅ Plugin compilou?
ls emulator/nitrowebsockets/target/NitroWebsockets-*.jar

# ✅ Plugin copiado para Arcturus?
docker exec -it arcturus ls /app/arcturus/target/plugins/

# ✅ Plugin carregou?
docker compose logs arcturus | grep -i websocket
```
