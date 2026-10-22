PROCEDURE AlteraProdutos()

    LOCAL nCodigo := 0
    LOCAL cDescricao := SPACE(40)
    LOCAL cUnidade   := SPACE(2)
    LOCAL nPreco     := 0
    LOCAL nEstoque   := 0

    CLEAR

    SET COLOR TO W/B
    SET ESCAPE ON
    SET CURSOR ON

    @ 2, 20 SAY "SISTEMA DE CONTROLE DE ESTOQUE"
    @ 3, 20 SAY "=============================="

    @ 5, 25 SAY "ALTERACAO DE PRODUTOS"
    @ 7, 2 SAY REPLICATE("-", 76)

    DO WHILE .T.
        nCodigo := 0
        cDescricao  := SPACE(40)
        cUnidade    := SPACE(2)
        nPreco      := 0
        nEstoque    := 0
        strResposta := SPACE(1)

        @ 13, 0 CLEAR TO 24, 79

        @ 10, 10 SAY "Codigo do Produto:"
        @ 10, 29 GET nCodigo PICTURE "999999"
        READ

        IF LASTKEY() == 27
            RETURN
        ENDIF

        USE PRODUTOS SHARED NEW

        IF NETERR()
            DO ExibeMensagem WITH "Erro ao abrir PRODUTOS.DBF", "ERRO"
        ELSE
            LOCATE FOR CODIGO == nCodigo
            IF FOUND()
            IF RLOCK()   
                cDescricao := DESCRICAO
                cUnidade   := UNIDADE
                nPreco     := PRECO
                nEstoque   := ESTOQUE

                @ 13, 10 SAY "Descricao:"
                @ 13, 25 GET cDescricao PICTURE "@!" ;
                    VALID ValidaCampo(cDescricao, "OBRIGATORIO", "A descricao deve ser informada.")

                @ 15, 10 SAY "Unidade:"
                @ 15, 25 GET cUnidade PICTURE "@!" ;
                    VALID ValidaCampo(cUnidade, "OBRIGATORIO", "A unidade deve ser informada.")

                @ 17, 10 SAY "Preco:"
                @ 17, 25 GET nPreco PICTURE "999999.99" ;
                    VALID ValidaCampo(nPreco, "POSITIVO", "O preco deve ser maior que zero.")

                @ 19, 10 SAY "Estoque:"
                @ 19, 25 GET nEstoque PICTURE "999999" ;
                    VALID ValidaCampo(nEstoque, "NAO_NEGATIVO", "O estoque nao pode ser negativo.")

                READ

                    IF LASTKEY() <> 27                    
                            REPLACE DESCRICAO WITH cDescricao
                            REPLACE UNIDADE   WITH cUnidade
                            REPLACE PRECO     WITH nPreco
                            REPLACE ESTOQUE   WITH nEstoque
                            DBCOMMIT()                        
                            DO ExibeMensagem WITH "Produto alterado com sucesso!", "SUCESSO"
                    ELSE
                        DO ExibeMensagem WITH "Alteracao cancelada.", "AVISO"
                    ENDIF
                DBUNLOCK()
            ELSE
                DO ExibeMensagem WITH "Registro bloqueado por outro usuario.", "ERRO"
            ENDIF      
            ELSE
                DO ExibeMensagem WITH "Produto nao encontrado.", "AVISO"
            ENDIF
            USE
        ENDIF

        @ 23,  2 SAY "Deseja alterar outro Produto (S/N)? "
        @ 23, 40 GET strResposta VALID ValidaCampo(strResposta, "SIM_NAO", ;
            "Informe somente S ou N.")  
        READ
        
        IF strResposta == "N" .OR. LASTKEY() == 27
            EXIT
        ENDIF    

    ENDDO    
RETURN