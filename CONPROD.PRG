PROCEDURE ConsultaProdutos()
        
    LOCAL nCodigo := 0
    LOCAL strResposta := SPACE(1)
    CLEAR
    @ 2, 20 SAY "SISTEMA DE CONTROLE DE ESTOQUE"
    @ 3, 20 SAY "=============================="

    @ 5, 25 SAY "CONSULTA DE PRODUTOS"
    @ 7, 2 SAY REPLICATE("-", 76)

    SET COLOR TO W/B
    SET ESCAPE ON
    SET CURSOR ON

    DO WHILE .T.
        @ 13,  0 SAY SPACE(79)
        @ 15,  0 SAY SPACE(79)
        @ 17,  0 SAY SPACE(79)
        @ 19,  0 SAY SPACE(79)
        @ 23,  0 SAY SPACE(79)
        nCodigo := 0
        strResposta := SPACE(1)
        @ 10, 10 SAY "Codigo do Produto:"
        @ 10, 29 GET nCodigo PICTURE "999999"
        READ

        IF LastKey() <> 27
            USE PRODUTOS SHARED NEW
            IF NETERR()
                DO ExibeMensagem WITH "Erro ao abrir PRODUTOS.DBF", "ERRO"
            ELSE
                LOCATE FOR CODIGO == nCodigo
                IF FOUND()
                    @ 13, 10 SAY "Descricao: [" + ALLTRIM(DESCRICAO)  + "]"
                    @ 15, 10 SAY "Unidade:   [" + UNIDADE    + "]"
                    @ 17, 10 SAY "Preco:     [" + STR(PRECO, 10, 2) + "]"
                    @ 19, 10 SAY "Estoque:   [" + STR(ESTOQUE, 6) + "]"
                ELSE
                    DO ExibeMensagem WITH "Produto nao encontrado.", "AVISO"
                ENDIF
                USE
            ENDIF
        ENDIF        
        
        @ 23,  2 SAY "Deseja consultar outro Produto (S/N)? "
        @ 23, 40 GET strResposta VALID ValidaCampo(strResposta, "SIM_NAO", ;
            "Informe somente S ou N.")  
        READ
        
        IF strResposta == "N" .OR. LASTKEY() == 27
            EXIT
        ENDIF    
    ENDDO    
RETURN