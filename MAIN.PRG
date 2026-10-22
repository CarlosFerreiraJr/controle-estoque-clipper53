DO MenuPrincipal

RETURN

PROCEDURE MenuPrincipal()    

   LOCAL aMenu := { "Produtos", "Movimentacao", "Estoque", ;
                    "Relatorios", "Manuten‡Æo", "Sair" }

   LOCAL aColunas := { 2, 14, 29, 41, 55, 69 }

   LOCAL nSubOpcao := 1
   LOCAL lSubMenu := .F.

   LOCAL nOpcao := 1
   LOCAL nTecla
   LOCAL nI
   LOCAL lExecutando := .T.

   SET SCOREBOARD OFF
   SET CURSOR OFF
   SET COLOR TO W/B
   SET DELETED ON

   DO WHILE lExecutando

      CLEAR

      @ 2, 20 SAY "SISTEMA DE CONTROLE DE ESTOQUE"
      @ 3, 20 SAY "=============================="

      DO WHILE .T.

         FOR nI := 1 TO LEN(aMenu)

            IF nI == nOpcao
               SET COLOR TO N/W
            ELSE
               SET COLOR TO W/B
            ENDIF

            @ 6, aColunas[nI] SAY aMenu[nI]

         NEXT

         SET COLOR TO W/B

         @ 24, 2 SAY "Setas: Navegar | ENTER: Selecionar | ESC: Sair"

         nTecla := INKEY(0)

         DO CASE

            CASE nTecla == 19
               nOpcao--

               IF nOpcao < 1
                  nOpcao := LEN(aMenu)
               ENDIF

            CASE nTecla == 4
               nOpcao++

               IF nOpcao > LEN(aMenu)
                  nOpcao := 1
               ENDIF

            CASE nTecla == 13
               EXIT

            CASE nTecla == 27
               nOpcao := LEN(aMenu)
               EXIT

         ENDCASE

      ENDDO

      SET COLOR TO W/B

      DO CASE

         CASE nOpcao == 1            
            DO MenuProdutos

         CASE nOpcao == 2
            CLEAR
            ? "Movimentacao de Estoque"
            WAIT "Pressione uma tecla..."

         CASE nOpcao == 3
            DO ConsultaEstoque

         CASE nOpcao == 4
            CLEAR
            ? "Relatorios"
            WAIT "Pressione uma tecla..."

         CASE nOpcao == 5                        
            DO ManutencaoProdutos            

         CASE nOpcao == 6
            lExecutando := .F.

      ENDCASE

   ENDDO

   SET CURSOR ON
   SET COLOR TO W/N
   CLEAR
   ? "Sistema encerrado."

RETURN


PROCEDURE MenuProdutos

   LOCAL aOpcoes := { "Cadastrar", "Consultar", "Alterar", ;
                      "Excluir", "Voltar" }

   LOCAL nOpcao := 1
   LOCAL nTecla
   LOCAL nI
   LOCAL nRetorno := 0

   SET COLOR TO W/B

   DO WHILE .T.

      FOR nI := 1 TO LEN(aOpcoes)

        IF nI == nOpcao
            SET COLOR TO N/W
        ELSE
            SET COLOR TO W/B
        ENDIF

         @ 7 + nI, 2 SAY PADR(aOpcoes[nI], 10)

      NEXT

      SET COLOR TO W/B

      @ 23, 0 SAY SPACE(80)
      @ 24, 0 SAY SPACE(80)
      @ 24, 2 SAY "Setas: Navegar | ENTER: Selecionar | ESC: Voltar"

      nTecla := INKEY(0)

      DO CASE

         CASE nTecla == 5
            nOpcao--

            IF nOpcao < 1
               nOpcao := LEN(aOpcoes)
            ENDIF

         CASE nTecla == 24
            nOpcao++

            IF nOpcao > LEN(aOpcoes)
               nOpcao := 1
            ENDIF

         CASE nTecla == 27
            EXIT

         CASE nTecla == 13

            IF nOpcao == 5
               EXIT
            ENDIF            

            DO CASE
               CASE nOpcao == 1
                  @ 23, 0 SAY SPACE(80)
                  @ 23, 2 SAY "Cadastro de Produtos"
                  nRetorno := 1
                  DO CadastroProdutos

               CASE nOpcao == 2
                  @ 23, 0 SAY SPACE(80)
                  @ 23, 2 SAY "Consulta de Produtos"
                  nRetorno := 1
                  DO ConsultaProdutos

               CASE nOpcao == 3
                  @ 23, 0 SAY SPACE(80)
                  @ 23, 2 SAY "Alteracao de Produtos"
                  nRetorno := 1
                  DO AlteraProdutos

               CASE nOpcao == 4
                  @ 23, 0 SAY SPACE(80)
                  @ 23, 2 SAY "Exclusao de Produtos"
                  nRetorno := 1
                  DO ExcluiProdutos
            ENDCASE

            IF nRetorno == 1
               nRetorno := 0
               EXIT 
            ENDIF

            @ 24, 0 SAY SPACE(80)
            @ 24, 2 SAY "Pressione uma tecla para continuar..."
            INKEY(0)            

      ENDCASE

   ENDDO

   SET COLOR TO W/B

RETURN

PROCEDURE ExibeMensagem(cMensagem, cTipo)

    LOCAL nLinha := 24
    LOCAL cCor   := "W/B"

    // Define o tipo da mensagem
    IF cTipo == NIL
        cTipo := "AVISO"
    ENDIF

    DO CASE
        CASE cTipo == "ERRO"
            cCor := "R+/B"
        CASE cTipo == "AVISO"
            cCor := "Y+/B"
        CASE cTipo == "SUCESSO"
            cCor := "GR+/B"
        OTHERWISE
            cCor := "W/B"
    ENDCASE

    // Exibe a mensagem
    SET COLOR TO (cCor)

    @ nLinha, 0 SAY SPACE(79)
    @ nLinha, 2 SAY cMensagem

    // Restaura a cor padrao
    SET COLOR TO W/B

RETURN

FUNCTION ValidaCampo(xValor, cRegra, cMensagem)
   LOCAL lValido := .T.
   
   DO CASE
      CASE cRegra == "POSITIVO"
         lValido := xValor > 0
      CASE cRegra == "OBRIGATORIO"
         lValido := !EMPTY(ALLTRIM(xValor))
      CASE cRegra == "NAO_NEGATIVO"
         lValido := xValor > 0
      CASE cRegra == "SIM_NAO"
        lValido := UPPER(ALLTRIM(xValor)) $ "SN" ;
                  .AND. !EMPTY(ALLTRIM(xValor))   
   ENDCASE

   IF !lValido      
      DO ExibeMensagem WITH cMensagem, "ERRO"
      INKEY(2)            
      DO ExibeMensagem WITH ""
   ELSE
      DO ExibeMensagem WITH ""
   ENDIF

RETURN lValido

PROCEDURE ManutencaoProdutos()

    USE PRODUTOS EXCLUSIVE NEW
    IF NETERR()
        DO ExibeMensagem WITH ;
            "Arquivo em uso. Nao foi possivel executar PACK.", "ERRO"
        RETURN
    ENDIF
    @ 13,10 SAY "Realizando manuten‡Æo nos arquivos de dados..."
    PACK
    USE
    @ 14,10 SAY "Manuten‡Æo realizada com sucesso!"
    @ 15,10 SAY "Pressione qualquer tecla para continuar"
    INKEY(0)
    @ 13, 0 CLEAR TO 15, 79

RETURN

PROCEDURE ConsultaEstoque()
    LOCAL nLinha := 12
    LOCAL nQtdProdutos := 0
    LOCAL nLinhasPorPagina := 0
    LOCAL nPagina := 1
    LOCAL nQtdPagina := 0    

    nQtdProdutos := ProximoCodigo() - 1
    nQtdPagina   := INT((nQtdProdutos + 7) / 8)

    USE PRODUTOS SHARED NEW

    IF NETERR()
        DO ExibeMensagem WITH "Erro ao abrir PRODUTOS.DBF... Pressione um tecla para contiunar", "ERRO"
        INKEY(0)
        RETURN
    ENDIF
    CLEAR

    @ 2, 20 SAY "SISTEMA DE CONTROLE DE ESTOQUE"
    @ 3, 20 SAY "=============================="

    @ 5, 25 SAY "LISTAGEM DE PRODUTOS DO ESTOQUE"
    @ 7, 2 SAY REPLICATE("-", 76)    

    GO TOP
    DO WHILE !EOF()       
       IF nLinha == 12
          @ 09,0 CLEAR TO 24,79
          @ 09, 10 SAY "+------------------------------+---------------------+"
          @ 10, 10 SAY "|         Descricao            |    Qtd. Produtos    |"
          @ 11, 10 SAY "+------------------------------+---------------------+"
       ENDIF

       IF nLinhasPorPagina > 7
          @ 12,0 CLEAR TO 20,79
          nLinhasPorPagina := 0  
          nLinha := 12
          nPagina := nPagina + 1
       ENDIF 

       @ nLinha, 10 SAY "| " + PADR(ALLTRIM(DESCRICAO), 29) + "|" + SPACE(5) + PADR(STR(ESTOQUE, 6),16) + "|"
       SKIP

       nLinha := nLinha + 1       
       nLinhasPorPagina := nLinhasPorPagina + 1             

       IF nLinhasPorPagina == 8
          @ nLinha, 10 SAY "+------------------------------+---------------------+"            
          @ 21, 10 SAY "Quantidade de Produtos no Estoque: [" + ALLTRIM(STR(nQtdProdutos, 6)) + "]"        
          @ 23, 10 SAY "P gina " + ALLTRIM(STR(nPagina)) + "/" + ALLTRIM(STR(nQtdPagina)) + "." + SPACE(5) + "Pressione uma tecla para continuar"
          INKEY(0)
       END IF  
    ENDDO        

    IF nLinhasPorPagina < 8
        @ nLinha, 10 SAY "+------------------------------+---------------------+"            
        @ 23,  0 SAY SPACE(79)
        @ 23, 10 SAY "P gina " + ALLTRIM(STR(nPagina)) + "/" + ALLTRIM(STR(nQtdPagina)) + "." + SPACE(5) + "Pressione uma tecla para sair."
        INKEY(0)    
    ENDIF    
    USE
RETURN  