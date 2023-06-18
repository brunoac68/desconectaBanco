#!/bin/bash

# Função para exibir a ajuda
display_help() {
    echo "Uso: $0 -d <nome_do_banco> -u <usuario> -s <senha> [-h <host>] [-p <porta>]"
    echo "Opções:"
    echo "  -d <nome_do_banco>    Nome do banco de dados"
    echo "  -u <usuario>          Usuário do banco de dados"
    echo "  -s <senha>            Senha do banco de dados"
    echo "  -h <host>             Endereço do banco de dados (padrão: localhost)"
    echo "  -p <porta>            Porta do banco de dados (padrão: 5432)"
    echo "  --help                Exibir esta mensagem de ajuda"
    exit 1
}

# Valores padrão
DB_HOST="localhost"
DB_PORT="5432"

# Processa os argumentos passados para o script
while getopts "d:u:s:h:p:-:" opt; do
    case "${opt}" in
        d)
            DB_NAME="${OPTARG}"
            ;;
        u)
            DB_USER="${OPTARG}"
            ;;
        s)
            DB_PASSWORD="${OPTARG}"
            ;;
        h)
            DB_HOST="${OPTARG}"
            ;;
        p)
            DB_PORT="${OPTARG}"
            ;;
        -)
            case "${OPTARG}" in
                help)
                    display_help
                    ;;
                *)
                    echo "Opção inválida: --${OPTARG}"
                    display_help
                    ;;
            esac
            ;;
        *)
            display_help
            ;;
    esac
done

# Verifica se todas as informações necessárias foram fornecidas
if [[ -z $DB_NAME ]] || [[ -z $DB_USER ]] || [[ -z $DB_PASSWORD ]]; then
    echo "Erro: Nome do banco de dados, usuário e senha são obrigatórios."
    display_help
fi

# Comando SQL para desconectar todos os usuários
SQL_COMMAND="SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = '$DB_NAME'
  AND pid <> pg_backend_pid();"

# Executa o comando SQL utilizando o utilitário psql
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "$SQL_COMMAND"
