# Windows USB Bootável no Ubuntu

Script automatizado para criar USB bootável do Windows (10/11) em sistemas Ubuntu/Linux.

## 📋 Dependências

```bash
sudo apt install parted dosfstools ntfs-3g rsync util-linux
```

## 🚀 Como usar

1. Clone e execute:
```bash
git clone https://github.com/seu-usuario/windows-usb-creator.git
cd windows-usb-creator
chmod +x create_windows11_usb.sh
sudo ./create_windows11_usb.sh
```

2. Forneça quando solicitado:
   - Caminho para ISO do Windows
   - Dispositivo USB (ex: `/dev/sdb`)
   - Confirmação digitando `SIM`

## 💾 Requisitos

- Ubuntu 18.04+ ou derivados
- Pendrive com pelo menos 8GB
- ISO oficial do Windows 10/11
- Acesso root (sudo)

## 🔧 O que faz

1. **Particiona** o USB com GPT (compatível com UEFI)
2. **Cria duas partições**:
   - FAT32 (1GB) - arquivos de boot
   - NTFS (restante) - arquivos de instalação
3. **Copia** todos os arquivos da ISO
4. **Prepara** o USB para boot UEFI

## ⚠️ Aviso

⚠️ **APAGA TODOS OS DADOS** do USB selecionado - faça backup antes de usar!
