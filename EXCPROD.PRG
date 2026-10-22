PROCEDURE ExcluiProdutos()

    LOCAL nCodigo := 0
    LOCAL cConfirma := SPACE(1)
    LOCAL strResposta := SPACE(1)

    SET COLOR TO W/B
    SET ESCAPE ON    
    SET CURSOR ON

    CLEAR

    @ 2, 20 SAY "SISTEMA DE CONTROLE DE ESTOQUE"
    @ 3, 20 SAY "=============================="

    @ 5, 25 SAY "EXCLUSAO DE PRODUTOS"
    @ 7, 2 SAY REPLICATE("-", 76)


    DO WHILE .T.

       @ 10, 0 CLEAR TO 24, 79
       
       nCodigo := 0
       cConfirma := SPACE(1)
       strResposta := SPACE(1)

        @ 10, 10 SAY "Codigo do Produto:"
        @ 10, 29 GET nCodigo PICTURE "999999"
        READ

        IF LASTKEY() == 27
            SET CURSOR OFF
            RETURN
        ENDIF

        USE PRODUTOS SHARED NEW

        IF NETERR()
            DO ExibeMensagem WITH "Erro ao abrir PRODUTOS.DBF", "ERRO"
        ELSE
            LOCATE FOR CODIGO == nCodigo
            IF FOUND()
                @ 13, 10 SAY "Descricao: [" + ALLTRIM(DESCRICAO) + "]"
                @ 15, 10 SAY "Unidade:   [" + UNIDADE + "]"
                @ 17, 10 SAY "Preco:     [" + STR(PRECO, 10, 2) + "]"
                @ 19, 10 SAY "Estoque:   [" + STR(ESTOQUE, 6) + "]"
                
                IF RLOCK()
                    cConfirma := SPACE(1)
                    @ 22, 10 SAY "Confirma exclusao (S/N)? "
                    @ 22, 38 GET cConfirma PICTURE "@!" ;
                            VALID ValidaCampo(cConfirma, "SIM_NAO", "Informe somente S ou N.")
                    READ

                    IF LASTKEY() <> 27 .AND. cConfirma == "S"
                        DELETE                        
                        DBCOMMIT()
                            IF DELETED()
                                DO ExibeMensagem WITH "Produto excluido com sucesso!", "SUCESSO"
                            ELSE
                                DO ExibeMensagem WITH "Erro ao excluir o registro!", "ERRO"
                            ENDIF
                    ELSE
                        DO ExibeMensagem WITH "Exclusao cancelada.", "AVISO"
                    ENDIF
                    DBUNLOCK()
                ELSE
                    DO ExibeMensagem WITH "Produto bloqueado por outro usuario.", "ERRO"
                ENDIF
            ELSE
                DO ExibeMensagem WITH "Produto nao encontrado.", "AVISO"
            ENDIF
            USE
        ENDIF
    
        @ 23,  2 SAY "Deseja excluir outro Produto (S/N)? "
        @ 23, 40 GET strResposta VALID ValidaCampo(strResposta, "SIM_NAO", ;
            "Informe somente S ou N.")  
        READ
        
        IF strResposta == "N" .OR. LASTKEY() == 27
            EXIT
        ENDIF    
    
    ENDDO
    SET CURSOR OFF

RETURN