Windows USB Bootável no Ubuntu
Um script Bash robusto e automatizado para criar USB bootável do Windows em sistemas Ubuntu/Linux, seguindo as melhores práticas de segurança e compatibilidade.
🚀 Características

Automatização completa do processo de criação de USB bootável
Particionamento GPT para compatibilidade com UEFI
Duas partições otimizadas: FAT32 (boot) + NTFS (instalação)
Validações rigorosas de entrada (ISO, dispositivo, dependências)
Interface colorida com logs informativos
Verificações de segurança para evitar perda acidental de dados
Tratamento robusto de erros com rollback automático

📋 Pré-requisitos
Sistema Operacional

Ubuntu 18.04+ ou distribuições baseadas em Debian
Acesso root (sudo)

Ferramentas Necessárias
bash# Instalar dependências (se não estiverem instaladas)
sudo apt update
sudo apt install parted dosfstools ntfs-3g rsync util-linux
Hardware

Pendrive USB com pelo menos 8GB (recomendado 16GB+)
ISO oficial do Windows

🛠️ Instalação

Clone este repositório:

bashgit clone https://github.com/seu-usuario/windows11-usb-creator.git
cd windows11-usb-creator

Torne o script executável:

bashchmod +x create_windows11_usb.sh
📖 Uso
Execução Básica
bashsudo ./create_windows11_usb.sh
O script irá solicitar interativamente:

Caminho para a ISO do Windows
Dispositivo USB de destino (ex: /dev/sdb)
Confirmação antes de proceder

Exemplo de Uso
bash$ sudo ./create_windows11_usb.sh

===================================================================
         Script para Criar USB Bootável do Windows
===================================================================

[INFO] Verificando dependências...
[SUCCESS] Todas as dependências estão instaladas
Digite o caminho completo para a ISO do Windows: /home/user/Downloads/Win11.iso
[SUCCESS] ISO validada: /home/user/Downloads/Win11.iso

[INFO] Dispositivos de bloco disponíveis:
NAME   SIZE  TYPE MODEL
sda  931.5G  disk Samsung SSD
sdb   14.9G  disk SanDisk Ultra

Digite o dispositivo USB (ex: /dev/sdb): /dev/sdb
[INFO] Dispositivo selecionado: /dev/sdb
[INFO] Tamanho: 14.9G
[INFO] Modelo: SanDisk Ultra

[WARNING] ATENÇÃO: Esta operação irá APAGAR TODOS OS DADOS em /dev/sdb
[WARNING] Esta ação é IRREVERSÍVEL!

Tem certeza que deseja continuar? Digite 'SIM' para confirmar: SIM
🔧 Estrutura das Partições
O script cria um layout otimizado para máxima compatibilidade:
PartiçãoTamanhoSistemaPropósitoBOOT1GBFAT32Arquivos de boot UEFIINSTALLRestanteNTFSArquivos de instalação
⚡ Funcionalidades Técnicas
Validações Implementadas

✅ Verificação de privilégios root
✅ Validação de dependências do sistema
✅ Verificação de integridade da ISO
✅ Detecção de dispositivos removíveis
✅ Confirmação de ações destrutivas

Recursos de Segurança

Limpeza automática de assinaturas antigas
Verificação de dispositivos removíveis
Confirmação explícita antes de formatar
Rollback automático em caso de erro

Otimizações

Particionamento GPT para UEFI moderno
Duas partições especializadas para melhor performance
Sincronização de dados antes de finalizar
Progresso visual durante cópia de arquivos

🐛 Resolução de Problemas
Erro: "Comando não encontrado"
bash# Instalar dependências faltantes
sudo apt install parted dosfstools ntfs-3g rsync util-linux
Erro: "Dispositivo não encontrado"
bash# Listar dispositivos disponíveis
lsblk -d
# Verificar se o USB está conectado
Erro: "Não é uma ISO válida"

Verifique se o arquivo não está corrompido
Baixe novamente a ISO oficial da Microsoft

USB não é detectado no boot

Verifique se o UEFI/BIOS está configurado para boot em USB
Desabilite Secure Boot temporariamente se necessário

🔍 Logs e Depuração
O script utiliza um sistema de logs coloridos:

🔵 [INFO] - Informações gerais
🟢 [SUCCESS] - Operações bem-sucedidas
🟡 [WARNING] - Avisos importantes
🔴 [ERROR] - Erros críticos

Para depuração adicional, execute com:
bashbash -x ./create_windows11_usb.sh
🤝 Contribuindo
Contribuições são bem-vindas! Por favor:

Faça um fork do projeto
Crie uma branch para sua feature (git checkout -b feature/nova-feature)
Commit suas mudanças (git commit -am 'Adiciona nova feature')
Push para a branch (git push origin feature/nova-feature)
Abra um Pull Request

📄 Licença
Este projeto está licenciado sob a licença MIT - veja o arquivo LICENSE para detalhes.
⚠️ Disclaimer

Este script é fornecido "como está", sem garantias
Sempre faça backup de dados importantes antes de usar
Teste em um ambiente controlado primeiro
O autor não se responsabiliza por perda de dados

🙏 Agradecimentos

Comunidade Ubuntu pela documentação
Contribuidores que reportaram bugs e melhorias
Microsoft pela disponibilização das ISOs oficiais


Nota: Este script foi desenvolvido e testado no Ubuntu 20.04+. Outras distribuições podem requerer ajustes nas dependências.
