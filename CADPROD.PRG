PROCEDURE CadastroProdutos()

   LOCAL nCodigo := 0
   LOCAL cDescricao := SPACE(40)
   LOCAL cUnidade := SPACE(2)
   LOCAL nPreco := 0
   LOCAL nEstoque := 0
   LOCAL nBotao := 1
   LOCAL nTecla
   LOCAL cConfirma := SPACE(1)

   SET COLOR TO W/B
   SET CURSOR ON

    DO WHILE .T.
        nCodigo := ProximoCodigo()
        
        IF nCodigo == 0
            DO ExibeMensagem WITH "Erro ao gerar codigo do produto.", "ERRO"
            EXIT
        ENDIF

        cDescricao := SPACE(40)
        cUnidade   := SPACE(2)
        nPreco     := 0
        nEstoque   := 0
        cConfirma := SPACE(1)

        CLEAR

        @ 2, 20 SAY "SISTEMA DE CONTROLE DE ESTOQUE"
        @ 3, 20 SAY "=============================="

        @ 5, 25 SAY "CADASTRO DE PRODUTOS"
        @ 7, 2 SAY REPLICATE("-", 76)

        @ 9, 5 SAY "Codigo....:"
        @ 9, 19 GET nCodigo PICTURE "999999" WHEN .F.

        @ 11, 5 SAY "Descricao.:"
        @ 11, 19 GET cDescricao PICTURE "@!" VALID ValidaCampo(cDescricao, "OBRIGATORIO", ;
            "A descricao deve ser informada.")

        @ 13, 5 SAY "Unidade...:"
        @ 13, 19 GET cUnidade PICTURE "@!" VALID ValidaCampo(cUnidade, "OBRIGATORIO", ;
            "A unidade deve ser informada.")

        @ 15, 5 SAY "Preco.....:"
        @ 15, 19 GET nPreco PICTURE "999999.99" VALID ValidaCampo(nPreco, "POSITIVO", ;
            "O preco deve ser maior que zero.")

        @ 17, 5 SAY "Estoque...:"
        @ 17, 19 GET nEstoque PICTURE "999999" VALID ValidaCampo(nEstoque, "NAO_NEGATIVO", ;
            "O estoque nao pode ser negativo.")

        READ

        IF LastKey() == 27
           nBotao := 0
        ELSE
           nBotao := 1
        ENDIF            
        
            // Escolha entre gravar e cancelar            
            DO WHILE .T. .AND. nBotao <> 0               
                SET COLOR TO W/B
                @ 20, 22 SAY "Deseja gravar o produto?"

                IF nBotao == 1
                    SET COLOR TO N/W
                ELSE
                    SET COLOR TO W/B
                ENDIF

                @ 22, 25 SAY "  GRAVAR  "
                IF nBotao == 2
                    SET COLOR TO N/W
                ELSE
                    SET COLOR TO W/B
                ENDIF

                @ 22, 43 SAY "  CANCELAR  "
                SET COLOR TO W/B
                nTecla := INKEY(0)

                DO CASE
                    CASE nTecla == 19
                        nBotao := 1
                    CASE nTecla == 4
                        nBotao := 2
                    CASE nTecla == 13
                        EXIT
                    CASE nTecla == 27
                        nBotao := 2
                        EXIT
                ENDCASE
            ENDDO    

            IF nBotao == 1 .AND. LastKey() <> 27
                USE PRODUTOS SHARED NEW
                IF NETERR()            
                    DO ExibeMensagem WITH "Erro ao abrir PRODUTOS.DBF", "ERRO"
                ELSE
                    APPEND BLANK
                    IF NETERR()                
                        DO ExibeMensagem WITH "Nao foi possivel incluir o produto.", "ERRO"
                    ELSE
                        REPLACE CODIGO    WITH nCodigo
                        REPLACE DESCRICAO WITH cDescricao
                        REPLACE UNIDADE   WITH cUnidade
                        REPLACE PRECO     WITH nPreco
                        REPLACE ESTOQUE   WITH nEstoque
                        DBCOMMIT()
                        DO ExibeMensagem WITH "Produto gravado com sucesso. Pressione uma tecla para continuar ", "SUCESSO"
                        INKEY(0)
                    ENDIF
                    USE
                ENDIF
            ELSE
              DO ExibeMensagem WITH "Cadastro cancelado.", "AVISO"
            ENDIF
        
        @ 20, 2 SAY SPACE(79)
        @ 22, 2 SAY SPACE(79)
        @ 24, 2 SAY SPACE(79)
        @ 24, 2 SAY "Deseja gravar outro Produto (S/N):"        
        @ 24, 36 GET cConfirma PICTURE "@!" VALID ValidaCampo(cConfirma, "SIM_NAO", ;
                    "Informe somente S ou N.")           
        READ

        IF cConfirma == "N" .OR. LastKey() == 27
          EXIT      
        ENDIF       

    END DO    
    CLEAR
    SET CURSOR OFF
RETURN

FUNCTION ProximoCodigo()
    LOCAL nMaior := 0
    LOCAL nProximo := 0

    USE PRODUTOS SHARED NEW

    IF NETERR()
        RETURN 0
    ENDIF

    GO TOP
    DO WHILE !EOF()
        IF CODIGO > nMaior
            nMaior := CODIGO
        ENDIF
        SKIP
    ENDDO
    nProximo := nMaior + 1
    USE
RETURN nProximo