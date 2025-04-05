#!/bin/bash

# Script otimizado para instalação do RClone com FUSE
set -euo pipefail  # Modo estrito para tratamento de erros

# Verifica privilégios root
if [ "$(id -u)" -ne 0 ]; then
    echo "🔴 Erro: Execute como root/sudo"
    exit 1
fi

# Função de verificação
check_install() {
    if command -v "$1" &>/dev/null; then
        echo "✅ $1 detectado"
        return 0
    else
        echo "❌ $1 não instalado"
        return 1
    fi
}

# Instalação com feedback visual
echo "🔄 Atualizando repositórios..."
apt-get update -qq

echo "📦 Instalando dependências..."
apt-get install -y -qq fuse curl unzip

echo "🚀 Instalando RClone..."
curl -s https://rclone.org/install.sh | sudo bash

# Verificação final
echo -e "\n🔍 Resultado da instalação:"
check_install rclone
check_install fuse

# Dicas pós-instalação
echo -e "\n💡 Dicas importantes:"
echo "1. Configuração: rclone config"
echo "2. Montagem: rclone mount remote:path /mnt/ponto_montagem"
echo "3. Documentação: https://rclone.org/docs/"
echo "4. Para usar montagens FUSE, talvez precise executar:"
echo "   sudo usermod -aG fuse \$USER"
echo "   (Reinicie a sessão após executar)"
