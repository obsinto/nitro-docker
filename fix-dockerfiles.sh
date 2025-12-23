#!/bin/bash

# Script para corrigir os Dockerfiles com imagens deprecadas
# Autor: Claude Code
# Data: 2025-12-23

echo "🔧 Iniciando correção dos Dockerfiles..."
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para verificar se arquivo existe
check_file() {
    if [ ! -f "$1" ]; then
        echo -e "${RED}❌ Erro: Arquivo $1 não encontrado!${NC}"
        return 1
    fi
    return 0
}

# Correção 1: emulator/Dockerfile
echo "📝 Corrigindo emulator/Dockerfile..."
if check_file "emulator/Dockerfile"; then
    sed -i 's/FROM openjdk:8-jdk-alpine/FROM eclipse-temurin:8-jdk-alpine/g' emulator/Dockerfile
    echo -e "${GREEN}✅ emulator/Dockerfile corrigido!${NC}"
    echo -e "   ${YELLOW}openjdk:8-jdk-alpine → eclipse-temurin:8-jdk-alpine${NC}"
else
    echo -e "${RED}⚠️  Pulando emulator/Dockerfile${NC}"
fi

echo ""

# Correção 2: emulator/arcturus/Dockerfile
echo "📝 Corrigindo emulator/arcturus/Dockerfile..."
if check_file "emulator/arcturus/Dockerfile"; then
    sed -i 's/FROM java:8 AS runner/FROM eclipse-temurin:8-jre-alpine AS runner/g' emulator/arcturus/Dockerfile
    echo -e "${GREEN}✅ emulator/arcturus/Dockerfile corrigido!${NC}"
    echo -e "   ${YELLOW}java:8 → eclipse-temurin:8-jre-alpine${NC}"
else
    echo -e "${RED}⚠️  Pulando emulator/arcturus/Dockerfile${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✨ Correções aplicadas com sucesso!${NC}"
echo ""
echo "📋 Próximos passos:"
echo "   1. Verifique as mudanças: git diff"
echo "   2. Faça commit: git add emulator/"
echo "   3. Commit: git commit -m 'fix: update deprecated Docker images'"
echo "   4. Push: git push origin main"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
