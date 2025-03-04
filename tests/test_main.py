from conectorcsv.main import extract_table_and_anomes

def test_extrai_nome_arquivo_anomes():

    _NOME_ARQUIVO = "vendas/2025/VENDAS_012025.csv"
    _NOME_TABELA = "vendas"
    _ANOMES = "202501"
    _COL_REF = "anomes"

    table_name, anomes, col_ref = extract_table_and_anomes(_NOME_ARQUIVO)
    assert table_name == _NOME_TABELA
    assert anomes == _ANOMES
    assert col_ref == _COL_REF


def test_extrai_nome_arquivo_ano():
    
    _NOME_ARQUIVO = "vendas/2025/VENDAS_2025.csv"
    _NOME_TABELA = "vendas"
    _ANOMES = "2025"
    _COL_REF = "ano"

    table_name, anomes, col_ref = extract_table_and_anomes(_NOME_ARQUIVO)
    assert table_name == _NOME_TABELA
    assert anomes == _ANOMES
    assert col_ref == _COL_REF


def test_extrai_nome_arquivo_invalido():
    _NOME_ARQUIVO = "tabela_dois9.csv"
    table_name, anomes, col_ref = extract_table_and_anomes(_NOME_ARQUIVO)
    assert table_name is None
    assert anomes is None
    assert col_ref is None
