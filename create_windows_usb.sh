#!/bin/bash

# =============================================================================
# Script para Criar USB Bootável do Windows 11 no Ubuntu
# =============================================================================
# 
# Descrição: Este script automatiza o processo de criação de um USB bootável
# do Windows 11 seguindo as melhores práticas. Ele formata o pendrive com
# partições GPT, copia os arquivos necessários e prepara o dispositivo para
# boot UEFI.
#
# Uso: sudo ./create_windows11_usb.sh
# 
# Requisitos:
# - Executar como root (sudo)
# - Ter as ferramentas: parted, mkfs.vfat, mkfs.ntfs, rsync, wipefs
# - ISO do Windows 11
# - Pendrive com pelo menos 8GB
#
# Autor: Assistente Claude
# Data: $(date +"%Y-%m-%d")
# =============================================================================

set -euo pipefail  # Parar em qualquer erro, variável não definida ou pipe com falha

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Função para verificar se o comando existe
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Comando '$1' não encontrado. Instale o pacote necessário."
        exit 1
    fi
}

# Função para verificar se está executando como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script deve ser executado como root (use sudo)"
        exit 1
    fi
}

# Função para verificar dependências
check_dependencies() {
    log_info "Verificando dependências..."
    local deps=("parted" "mkfs.vfat" "mkfs.ntfs" "rsync" "wipefs" "mount" "umount" "lsblk")
    
    for dep in "${deps[@]}"; do
        check_command "$dep"
    done
    
    log_success "Todas as dependências estão instaladas"
}

# Função para listar dispositivos disponíveis
list_devices() {
    log_info "Dispositivos de bloco disponíveis:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep -E "(disk|loop)" || true
}

# Função para validar se o arquivo ISO existe
validate_iso() {
    local iso_path="$1"
    
    if [[ ! -f "$iso_path" ]]; then
        log_error "Arquivo ISO não encontrado: $iso_path"
        exit 1
    fi
    
    # Verificar se é um arquivo ISO válido
    if ! file "$iso_path" | grep -q "ISO 9660"; then
        log_error "O arquivo fornecido não parece ser uma ISO válida"
        exit 1
    fi
    
    log_success "ISO validada: $iso_path"
}

# Função para validar dispositivo USB
validate_device() {
    local device="$1"
    
    if [[ ! -b "$device" ]]; then
        log_error "Dispositivo não encontrado: $device"
        exit 1
    fi
    
    # Verificar se é um dispositivo removível
    local device_name=$(basename "$device")
    if [[ -f "/sys/block/$device_name/removable" ]]; then
        local removable=$(cat "/sys/block/$device_name/removable")
        if [[ "$removable" != "1" ]]; then
            log_warning "ATENÇÃO: $device pode não ser um dispositivo removível!"
        fi
    fi
    
    # Mostrar informações do dispositivo
    local size=$(lsblk -d -n -o SIZE "$device" 2>/dev/null || echo "Desconhecido")
    local model=$(lsblk -d -n -o MODEL "$device" 2>/dev/null || echo "Desconhecido")
    
    log_info "Dispositivo selecionado: $device"
    log_info "Tamanho: $size"
    log_info "Modelo: $model"
}

# Função para confirmar ação destrutiva
confirm_action() {
    local device="$1"
    
    echo
    log_warning "ATENÇÃO: Esta operação irá APAGAR TODOS OS DADOS em $device"
    log_warning "Esta ação é IRREVERSÍVEL!"
    echo
    
    read -p "Tem certeza que deseja continuar? Digite 'SIM' para confirmar: " confirmation
    
    if [[ "$confirmation" != "SIM" ]]; then
        log_info "Operação cancelada pelo usuário"
        exit 0
    fi
}

# Função para criar pontos de montagem
create_mount_points() {
    log_info "Criando pontos de montagem..."
    
    mkdir -p /mnt/{iso,vfat,ntfs}
    
    # Verificar se os diretórios foram criados
    if [[ ! -d "/mnt/iso" ]] || [[ ! -d "/mnt/vfat" ]] || [[ ! -d "/mnt/ntfs" ]]; then
        log_error "Falha ao criar pontos de montagem"
        exit 1
    fi
}

# Função para limpar montagens anteriores
cleanup_mounts() {
    log_info "Limpando montagens anteriores..."
    
    # Tentar desmontar se estiver montado (ignorar erros)
    umount /mnt/iso 2>/dev/null || true
    umount /mnt/vfat 2>/dev/null || true
    umount /mnt/ntfs 2>/dev/null || true
}

# Função para particionar o dispositivo
partition_device() {
    local device="$1"
    
    log_info "Limpando assinaturas do dispositivo..."
    wipefs -a "$device"
    
    log_info "Criando tabela de partições GPT..."
    parted "$device" --script mklabel gpt
    
    log_info "Criando partição BOOT (FAT32, 1GiB)..."
    parted "$device" --script mkpart BOOT fat32 0% 1GiB
    
    log_info "Criando partição INSTALL (NTFS, restante do espaço)..."
    parted "$device" --script mkpart INSTALL ntfs 1GiB 100%
    
    # Aguardar o kernel reconhecer as partições
    sleep 2
    partprobe "$device"
    sleep 2
    
    log_success "Particionamento concluído"
}

# Função para formatar e montar partições
format_and_mount() {
    local device="$1"
    
    log_info "Formatando partição BOOT como FAT32..."
    mkfs.vfat -n BOOT "${device}1"
    
    log_info "Formatando partição INSTALL como NTFS..."
    mkfs.ntfs --quick -L INSTALL "${device}2"
    
    log_info "Montando partições..."
    mount "${device}1" /mnt/vfat
    mount "${device}2" /mnt/ntfs
    
    log_success "Partições formatadas e montadas"
}

# Função para montar ISO
mount_iso() {
    local iso_path="$1"
    
    log_info "Montando ISO do Windows 11..."
    mount -o loop "$iso_path" /mnt/iso
    
    log_success "ISO montada em /mnt/iso"
}

# Função para copiar arquivos para partição BOOT
copy_to_boot_partition() {
    log_info "Copiando arquivos para partição BOOT (exceto sources)..."
    
    # Usar rsync para mostrar progresso
    rsync -r --progress --exclude sources --delete-before /mnt/iso/ /mnt/vfat/
    
    log_info "Criando diretório sources na partição BOOT..."
    mkdir -p /mnt/vfat/sources
    
    log_info "Copiando boot.wim para partição BOOT..."
    cp /mnt/iso/sources/boot.wim /mnt/vfat/sources/
    
    log_success "Arquivos copiados para partição BOOT"
}

# Função para copiar arquivos para partição INSTALL
copy_to_install_partition() {
    log_info "Copiando todos os arquivos para partição INSTALL..."
    
    # Usar rsync para mostrar progresso
    rsync -r --progress --delete-before /mnt/iso/ /mnt/ntfs/
    
    log_success "Arquivos copiados para partição INSTALL"
}

# Função para finalizar e desmontar
finalize() {
    local device="$1"
    
    log_info "Desmontando sistemas de arquivos..."
    umount /mnt/ntfs
    umount /mnt/vfat
    umount /mnt/iso
    
    log_info "Sincronizando dados..."
    sync
    
    log_info "Desligando dispositivo USB..."
    udisksctl power-off -b "$device" || true
    
    log_success "USB bootável do Windows 11 criado com sucesso!"
    log_info "Você pode remover o dispositivo com segurança"
}

# Função principal
main() {
    local iso_path=""
    local device=""
    
    echo "==================================================================="
    echo "         Script para Criar USB Bootável do Windows 11"
    echo "==================================================================="
    echo
    
    # Verificações iniciais
    check_root
    check_dependencies
    
    # Solicitar caminho da ISO
    while [[ -z "$iso_path" ]]; do
        read -p "Digite o caminho completo para a ISO do Windows 11: " iso_path
        if [[ -n "$iso_path" ]]; then
            validate_iso "$iso_path"
        fi
    done
    
    echo
    list_devices
    echo
    
    # Solicitar dispositivo USB
    while [[ -z "$device" ]]; do
        read -p "Digite o dispositivo USB (ex: /dev/sdb): " device
        if [[ -n "$device" ]]; then
            validate_device "$device"
        fi
    done
    
    # Confirmar ação
    confirm_action "$device"
    
    # Executar processo
    create_mount_points
    cleanup_mounts
    
    log_info "Iniciando processo de criação do USB bootável..."
    
    partition_device "$device"
    format_and_mount "$device"
    mount_iso "$iso_path"
    copy_to_boot_partition
    copy_to_install_partition
    finalize "$device"
    
    echo
    log_success "Processo concluído com sucesso!"
    echo "Seu USB bootável do Windows 11 está pronto para uso."
}

# Executar função principal se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
