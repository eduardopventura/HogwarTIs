#!/bin/bash

# Configuração de diretórios (mesma estrutura do service_manager_all.sh)
SCRIPTS_DIR="$(dirname "$(realpath "$0")")"
BASE_DIR="$(dirname "$SCRIPTS_DIR")"
SERVICES_DIR="$BASE_DIR/services"

# Função para habilitar serviços
enable_service() {
    local service_name=$1
    local service_file="$SERVICES_DIR/$service_name.service"

    echo "🔄 Processando serviço $service_name..."

    # Verifica se o arquivo .service existe
    if [ ! -f "$service_file" ]; then
        echo "❌ Erro: Arquivo $service_name.service não encontrado em $SERVICES_DIR"
        return 1
    fi

    # Copia o arquivo de serviço
    echo "📋 Copiando $service_name.service para /etc/systemd/system/"
    sudo cp "$service_file" /etc/systemd/system/

    # Recarrega o systemd
    sudo systemctl daemon-reload

    # Habilita e inicia o serviço
    echo "⚡ Habilitando e iniciando o serviço..."
    sudo systemctl enable "$service_name.service"
    sudo systemctl start "$service_name.service"

    # Verifica o status
    if systemctl is-active --quiet "$service_name.service"; then
        echo "✅ $service_name ativado com sucesso"
    else
        echo "⚠️ Aviso: $service_name foi configurado mas não está ativo"
        systemctl status "$service_name.service" --no-pager
        return 1
    fi
}

# Execução principal
echo "🔧 Iniciando processo de ativação de serviços..."

# Verifica argumentos
if [ $# -eq 0 ]; then
    echo "ℹ️ Uso: $0 service1 [service2 ...]"
    echo "⚠️ Nenhum serviço especificado. Saindo."
    exit 1
fi

# Verifica se o diretório de serviços existe
if [ ! -d "$SERVICES_DIR" ]; then
    echo "❌ Erro: Diretório de serviços não encontrado em $SERVICES_DIR"
    exit 1
fi

# Processa cada serviço
for service in "$@"; do
    enable_service "$service" || continue
done

# Resumo final
echo -e "\n📊 Resumo da operação:"
for service in "$@"; do
    status=$(systemctl is-active "$service.service" 2>/dev/null || echo "not-found")
    case $status in
        active) echo "✅ $service - Ativo e rodando" ;;
        failed) echo "❌ $service - Falhou ao iniciar" ;;
        *) echo "⚠️ $service - Estado desconhecido ou não encontrado" ;;
    esac
done

echo -e "\n🎉 Concluído! Serviços processados: $*"
