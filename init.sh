#!/bin/bash

# Diretório de origem
source_dir="./conectorcsv"

# Verifica se o diretório existe
if [ ! -d "$source_dir" ]; then
    echo "Erro: O diretório '$source_dir' não foi encontrado."
    exit 1
fi

# Cria o arquivo zip com o conteúdo do diretório
(cd "$source_dir" && zip -r ../function-source.zip .)

# Verifica se o zip foi criado com sucesso
if [ $? -eq 0 ]; then
    echo "Arquivo 'function-source.zip' criado com sucesso!"
else
    echo "Falha ao criar o arquivo zip."
    exit 1
fi