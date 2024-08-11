#!/bin/bash

# Listas
diretorios=("/adm" "/venv" "/sec" "/publico") 
grupos=("GRP_ADM" "GRP_VEN" "GRP_SEC" "root")
usuarios_adm=("carlos" "maria" "joao")
usuarios_ven=("debora" "sebastiana" "roberto")
usuarios_sec=("josefina" "amanda" "rogerio")

# Adicionar diretórios
for diretorio in "${diretorios[@]}"; do
    mkdir -p "$diretorio"
done

# Criar os grupos
for grupo in "${grupos[@]}"; do
    if ! getent group "$grupo" > /dev/null 2>&1; then
        groupadd "$grupo"
        echo "Grupo $grupo criado"
    else
        echo "Grupo $grupo já existe"
    fi
done

# Definir grupos e permissões para diretórios
for i in "${!grupos[@]}"; do
    grupo="${grupos[$i]}"
    diretorio="${diretorios[$i]}"

    if [ -d "$diretorio" ]; then
        chgrp "$grupo" "$diretorio"
        if [ "$diretorio" == "/publico" ]; then
            chmod 777 "$diretorio"
				    ls -ld "$diretorio"
        else
            chmod 770 "$diretorio"
				    ls -ld "$diretorio"
        fi
        echo "Grupo $grupo definido para o diretório $diretorio"
    else
        echo "Diretório $diretorio não encontrado"
    fi

done

# Função para criar usuários
criar_usuarios() {
    local grupo="$1"
    shift  # Remove o primeiro argumento (grupo), deixando apenas os usuários

    local usuarios=("$@")

    # Verifica se foi fornecida a lista de usuários
    if [ ${#usuarios[@]} -eq 0 ]; then
        echo "Nenhum usuário disponível."
        return 1
    fi

    # Adiciona os usuários
    for usuario in "${usuarios[@]}"; do
        if [ -n "$usuario" ]; then
            if id "$usuario" &>/dev/null; then
                echo "Usuário $usuario já existe"
            else
                # Adiciona o usuário e o adiciona ao grupo
                useradd "$usuario" -s /bin/bash -m -p "$(openssl passwd Senha123)" -G "$grupo"
                echo "Usuário $usuario criado e adicionado ao grupo $grupo"
            fi
        fi
    done
}

# Criando os usuários
criar_usuarios "${grupos[0]}" "${usuarios_adm[@]}"
criar_usuarios "${grupos[1]}" "${usuarios_ven[@]}"
criar_usuarios "${grupos[2]}" "${usuarios_sec[@]}"
