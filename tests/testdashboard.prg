/*
TESTDASHBOARD - Painel de vendas em FiveWin + chartclass, com clique do mouse nos gráficos
2026.11 José Quintas

Dados fictícios gerados no próprio programa: um registro por pedido.

Clique em barra, fatia ou legenda filtra; clique de novo no mesmo tira.
Duplo clique no cliente filtra o cliente, de novo tira. Limpar tira todos, menos o ano.
O que não está no filtro fica em cor clara.
*/

#include "fivewin.ch"
#include "ze_chartclass.ch"

REQUEST HB_CODEPAGE_PTISO

#define D_ANO          1
#define D_MES          2
#define D_VEND         3
#define D_UF           4
#define D_GRUPO        5
#define D_CLI          6
#define D_VALOR        7
#define D_CUSTO        8

#define G_NOME         1
#define G_VALOR        2
#define G_CUSTO        3
#define G_QTD          4

#define CLIQUE_ESQUERDO 0x201   // RMC_LBUTTONDOWN, no .ch está como &H201
#define TODOS           "(Todos)"

// cores RRGGBB, como no HTML
#define COR_FUNDO      RGB( 243, 242, 241 )
#define COR_TITULO     0x252423
#define COR_TEXTO      0x605E5C
#define COR_AZUL       0x118DFF
#define COR_AZUL2      0x12239E
#define COR_LARANJA    0xE66C37
#define COR_ROXO       0x744EC2

#define LARGURA        1280
#define MARGEM         10

STATIC s_aDados  := {}
STATIC s_hF                      // filtros: ANO, MES (0 = todos), VEND, UF, GRUPO, CLI ("" = todos)
STATIC s_hId     := { => }       // id de cada gráfico
STATIC s_hLista  := { => }       // nomes na ordem do gráfico, pra saber o que foi clicado
STATIC s_aAnos   := {}
STATIC s_aVend   := {}
STATIC s_aUf     := {}
STATIC s_aGrupos := {}
STATIC s_aTop    := {}
STATIC s_hUltMes := { => }
STATIC s_oChart, s_oSayFiltro, s_oBrw, s_hCbx := { => }
STATIC s_nAltMes, s_nAltBar       // altura dos gráficos, pela altura da tela

PROCEDURE Main

   LOCAL oDlg, oFont, oBtn, cAno, cVend := TODOS, cUf := TODOS, cGrupo := TODOS, nX, nLarg, nAltCli, nResto, nAltBrw

   hb_cdpSelect( "PTISO" )
   SET DATE BRITISH
   GeraDados()
   s_hF := { "ANO" => ATail( s_aAnos ), "MES" => 0, "VEND" => "", "UF" => "", "GRUPO" => "", "CLI" => "" }
   cAno := Ltrim( Str( s_hF[ "ANO" ] ) )
   s_oChart := ChartClass():New()

   FW_SetTruePixel( .T. )
   // SM_CYFULLSCREEN = altura livre da tela, sem barra de título e sem barra de tarefas
   nAltCli   := Min( 850, GetSysMetrics( 17 ) - 40 )
   nResto    := nAltCli - 68 - 85 - 4 * MARGEM
   s_nAltMes := Int( nResto * 0.37 )
   s_nAltBar := Int( nResto * 0.32 )
   nAltBrw   := nResto - s_nAltMes - s_nAltBar
   DEFINE FONT oFont NAME "Segoe UI" SIZE 0, -12
   DEFINE DIALOG oDlg TITLE "Painel de Vendas" SIZE LARGURA, nAltCli + 40 PIXEL COLOR CLR_BLACK, COR_FUNDO FONT oFont

   nX := MARGEM
   @ 14, nX SAY "Ano" OF oDlg PIXEL SIZE 30, 20 TRANSPARENT
   @ 10, nX + 30 COMBOBOX s_hCbx[ "ANO" ] VAR cAno ITEMS AnosTexto() OF oDlg PIXEL SIZE 70, 300
   s_hCbx[ "ANO" ]:bChange := { || s_hF[ "ANO" ] := Val( cAno ), Redesenha() }
   nX += 120
   @ 14, nX SAY "Vendedor" OF oDlg PIXEL SIZE 60, 20 TRANSPARENT
   @ 10, nX + 60 COMBOBOX s_hCbx[ "VEND" ] VAR cVend ITEMS ComTodos( s_aVend ) OF oDlg PIXEL SIZE 140, 300
   s_hCbx[ "VEND" ]:bChange := { || s_hF[ "VEND" ] := iif( cVend == TODOS, "", cVend ), Redesenha() }
   nX += 220
   @ 14, nX SAY "UF" OF oDlg PIXEL SIZE 25, 20 TRANSPARENT
   @ 10, nX + 25 COMBOBOX s_hCbx[ "UF" ] VAR cUf ITEMS ComTodos( s_aUf ) OF oDlg PIXEL SIZE 80, 300
   s_hCbx[ "UF" ]:bChange := { || s_hF[ "UF" ] := iif( cUf == TODOS, "", cUf ), Redesenha() }
   nX += 125
   @ 14, nX SAY "Grupo" OF oDlg PIXEL SIZE 40, 20 TRANSPARENT
   @ 10, nX + 40 COMBOBOX s_hCbx[ "GRUPO" ] VAR cGrupo ITEMS ComTodos( s_aGrupos ) OF oDlg PIXEL SIZE 130, 300
   s_hCbx[ "GRUPO" ]:bChange := { || s_hF[ "GRUPO" ] := iif( cGrupo == TODOS, "", cGrupo ), Redesenha() }
   nX += 190
   @ 9, nX BUTTON oBtn PROMPT "Limpar filtros" OF oDlg PIXEL SIZE 110, 26
   oBtn:bAction := { || s_hF[ "MES" ] := 0, s_hF[ "VEND" ] := "", s_hF[ "UF" ] := "", s_hF[ "GRUPO" ] := "", s_hF[ "CLI" ] := "", Redesenha() }

   @ 44, MARGEM SAY s_oSayFiltro PROMPT "" OF oDlg PIXEL SIZE LARGURA - 2 * MARGEM, 20 TRANSPARENT COLOR RGB( 18, 35, 158 ), COR_FUNDO

   nLarg := LARGURA - 2 * MARGEM - 16
   @ 68 + 85 + s_nAltMes + s_nAltBar + 3 * MARGEM, MARGEM XBROWSE s_oBrw ARRAY s_aTop ;
      COLUMNS 1, 2, 3, 4, 5 ;
      HEADERS "Top 10 clientes", "Faturamento", "Pedidos", "Ticket médio", "Margem %" ;
      PICTURES NIL, "@E 999,999,999.99", "@E 99,999", "@E 999,999,999.99", "@E 999.9" ;
      COLSIZES Int( nLarg * 0.40 ), Int( nLarg * 0.18 ), Int( nLarg * 0.12 ), Int( nLarg * 0.18 ), Int( nLarg * 0.12 ) ;
      OF oDlg PIXEL SIZE nLarg, nAltBrw NOBORDER
   s_oBrw:nMarqueeStyle := MARQSTYLE_HIGHLROW
   s_oBrw:lHScroll      := .F.
   s_oBrw:bClrStd       := { || iif( Len( s_aTop ) >= s_oBrw:nArrayAt .AND. ! Empty( s_hF[ "CLI" ] ) .AND. ;
      s_aTop[ s_oBrw:nArrayAt, 1 ] == s_hF[ "CLI" ], { CLR_BLACK, RGB( 222, 236, 249 ) }, { CLR_BLACK, CLR_WHITE } ) }
   s_oBrw:bLDblClick    := { || CliqueCliente() }
   s_oBrw:CreateFromCode()

   oDlg:bInit := { || CriaGraficos( oDlg ) }
   ACTIVATE DIALOG oDlg CENTER

   FOR EACH nX IN hb_HValues( s_hId )
      s_oChart:DeleteChart( nX )
   NEXT
   oFont:End()

   RETURN

/* cria os gráficos uma vez; depois cada filtro faz Reset() e desenha de novo, o clique continua */
STATIC FUNCTION CriaGraficos( oDlg )

   LOCAL hWnd := oDlg:hWnd, nLarg := LARGURA - 2 * MARGEM - 16, nTerco, nX, nY

   nY := 68
   Cria( "KPI",    hWnd, MARGEM, nY, nLarg, 85 )
   nY += 85 + MARGEM
   nX := Int( nLarg * 0.62 )
   Cria( "MES",    hWnd, MARGEM, nY, nX, s_nAltMes )
   Cria( "GRUPO",  hWnd, MARGEM * 2 + nX, nY, nLarg - nX - MARGEM, s_nAltMes )
   nY += s_nAltMes + MARGEM
   nTerco := Int( ( nLarg - 2 * MARGEM ) / 3 )
   Cria( "VEND",   hWnd, MARGEM, nY, nTerco, s_nAltBar )
   Cria( "UF",     hWnd, MARGEM * 2 + nTerco, nY, nTerco, s_nAltBar )
   Cria( "MARGEM", hWnd, MARGEM * 3 + nTerco * 2, nY, nLarg - 2 * nTerco - 2 * MARGEM, s_nAltBar )

   CHC_SetOnClick( s_hId[ "MES" ],    { | h | Clique( h, "MES" ) } )
   CHC_SetOnClick( s_hId[ "GRUPO" ],  { | h | Clique( h, "GRUPO" ) } )
   CHC_SetOnClick( s_hId[ "VEND" ],   { | h | Clique( h, "VEND" ) } )
   CHC_SetOnClick( s_hId[ "UF" ],     { | h | Clique( h, "UF" ) } )
   CHC_SetOnClick( s_hId[ "MARGEM" ], { | h | Clique( h, "MARGEM" ) } )
   Redesenha()

   RETURN NIL

STATIC FUNCTION Cria( cNome, hWnd, nX, nY, nW, nH )

   LOCAL nId := s_oChart:GetChartId()

   s_oChart:CreateChart( hWnd, nId, nX, nY, nW, nH, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .F., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   s_hId[ cNome ]    := nId
   s_hLista[ cNome ] := {}

   RETURN NIL

/* clique num gráfico: o nome do ponto vira filtro, o mesmo de novo tira */
STATIC FUNCTION Clique( hInfo, cGrafico )

   LOCAL nPos, aLista := s_hLista[ cGrafico ], cCampo

   IF hInfo[ "EVENT" ] != CLIQUE_ESQUERDO
      RETURN NIL
   ENDIF
   DO CASE
   CASE hInfo[ "TYPE" ] $ "BAR,LINE,PIE"
      nPos := hInfo[ "POINT" ]
   CASE hInfo[ "TYPE" ] == "LEGEND" .AND. cGrafico == "GRUPO"
      nPos := hInfo[ "ITEM" ]
   OTHERWISE
      RETURN NIL
   ENDCASE
   IF nPos < 1 .OR. nPos > Len( aLista )
      RETURN NIL
   ENDIF
   IF cGrafico == "MES"
      s_hF[ "MES" ] := iif( s_hF[ "MES" ] == nPos, 0, nPos )
   ELSE
      cCampo := iif( cGrafico == "MARGEM", "GRUPO", cGrafico )
      s_hF[ cCampo ] := iif( s_hF[ cCampo ] == aLista[ nPos ], "", aLista[ nPos ] )
   ENDIF
   Redesenha()

   RETURN NIL

STATIC FUNCTION CliqueCliente()

   LOCAL cCli

   IF s_oBrw:nArrayAt < 1 .OR. s_oBrw:nArrayAt > Len( s_aTop ) .OR. s_aTop[ s_oBrw:nArrayAt, 3 ] == 0
      RETURN NIL
   ENDIF
   cCli := s_aTop[ s_oBrw:nArrayAt, 1 ]
   s_hF[ "CLI" ] := iif( s_hF[ "CLI" ] == cCli, "", cCli )
   Redesenha()

   RETURN NIL

STATIC FUNCTION Redesenha()

   SincCombos()
   MostraFiltro()
   GrafKpi()
   GrafMes()
   GrafGrupo()
   GrafBarras( "VEND", "Por vendedor", COR_AZUL )
   GrafBarras( "UF", "Por UF", COR_AZUL2 )
   GrafMargem()
   TabClientes()

   RETURN NIL

/* ---------------------------------------------------------------- dados */

/* pedidos fictícios, sempre os mesmos (semente fixa): 2024 e 2025 inteiros, 2026 até outubro */
STATIC FUNCTION GeraDados()

   LOCAL aVend  := { "Ana Souza", "Bruno Lima", "Carla Dias", "Diego Rocha", "Elisa Mota", "Fábio Nunes" }
   LOCAL aUf    := { "SP", "SP", "SP", "SP", "SP", "PR", "PR", "MG", "MG", "RJ", "RJ", "GO", "SC", "BA" }
   // grupo, valor mínimo, valor máximo, margem mínima %, margem máxima %
   LOCAL aGrupo := { ;
      { "Combustíveis",  5000, 25000,  5,  9 }, ;
      { "Lubrificantes", 1000,  4500, 26, 32 }, ;
      { "Graxas",         400,  3000, 30, 34 }, ;
      { "Filtros",        300,  1500, 33, 38 }, ;
      { "Aditivos",       300,  1000, 40, 45 } }
   LOCAL aCli := {}, cTipo, cNome, nAno, nMes, nPedido, nQtd, aG, nValor, nMargem, aReg

   FOR EACH cNome IN { "Alfa", "Vale Verde", "Rio Claro", "Horizonte", "Central" }
      FOR EACH cTipo IN { "Auto Posto", "Transportes", "Mecânica", "Agro", "Frota", "Locadora", "Distribuidora", "Usina" }
         AAdd( aCli, cTipo + " " + cNome )
      NEXT
   NEXT
   hb_RandomSeed( 2026 )
   FOR nAno := 2024 TO 2026
      FOR nMes := 1 TO iif( nAno == 2026, 10, 12 )
         nQtd := 65 + ( nAno - 2024 ) * 4 + hb_RandomInt( 0, 20 )
         FOR nPedido := 1 TO nQtd
            aG      := aGrupo[ hb_RandomInt( 1, Len( aGrupo ) ) ]
            nValor  := Round( aG[ 2 ] + hb_Random() * ( aG[ 3 ] - aG[ 2 ] ), 2 )
            nMargem := aG[ 4 ] + hb_Random() * ( aG[ 5 ] - aG[ 4 ] )
            // primeiros clientes compram mais
            AAdd( s_aDados, { nAno, nMes, aVend[ hb_RandomInt( 1, Len( aVend ) ) ], aUf[ hb_RandomInt( 1, Len( aUf ) ) ], ;
               aG[ 1 ], aCli[ Int( Len( aCli ) * hb_Random() ^ 2 ) + 1 ], nValor, Round( nValor * ( 1 - nMargem / 100 ), 2 ) } )
         NEXT
      NEXT
   NEXT
   FOR EACH aReg IN s_aDados
      Junta( s_aAnos, aReg[ D_ANO ] )
      Junta( s_aVend, aReg[ D_VEND ] )
      Junta( s_aUf, aReg[ D_UF ] )
      Junta( s_aGrupos, aReg[ D_GRUPO ] )
      s_hUltMes[ aReg[ D_ANO ] ] := Max( hb_HGetDef( s_hUltMes, aReg[ D_ANO ], 0 ), aReg[ D_MES ] )
   NEXT
   ASort( s_aAnos )

   RETURN NIL

STATIC FUNCTION Junta( aLista, xValor )

   IF AScan( aLista, { | x | x == xValor } ) == 0
      AAdd( aLista, xValor )
   ENDIF

   RETURN NIL

/* registros do ano com os filtros, menos o filtro cSem (o gráfico daquele campo mostra todos e destaca o escolhido) */
STATIC FUNCTION Filtra( cSem, nAno )

   LOCAL aLista := {}, aReg

   hb_Default( @cSem, "" )
   hb_Default( @nAno, s_hF[ "ANO" ] )
   FOR EACH aReg IN s_aDados
      IF aReg[ D_ANO ] == nAno .AND. ;
         ( cSem == "MES"   .OR. s_hF[ "MES" ] == 0      .OR. aReg[ D_MES ]   == s_hF[ "MES" ] ) .AND. ;
         ( cSem == "VEND"  .OR. Empty( s_hF[ "VEND" ] )  .OR. aReg[ D_VEND ]  == s_hF[ "VEND" ] ) .AND. ;
         ( cSem == "UF"    .OR. Empty( s_hF[ "UF" ] )    .OR. aReg[ D_UF ]    == s_hF[ "UF" ] ) .AND. ;
         ( cSem == "GRUPO" .OR. Empty( s_hF[ "GRUPO" ] ) .OR. aReg[ D_GRUPO ] == s_hF[ "GRUPO" ] ) .AND. ;
         ( cSem == "CLI"   .OR. Empty( s_hF[ "CLI" ] )   .OR. aReg[ D_CLI ]   == s_hF[ "CLI" ] )
         AAdd( aLista, aReg )
      ENDIF
   NEXT

   RETURN aLista

/* { { nome, valor, custo, pedidos } }, do maior valor pro menor */
STATIC FUNCTION Agrupa( aRegs, nCampo )

   LOCAL hGrupo := { => }, aReg, aLista := {}

   FOR EACH aReg IN aRegs
      IF ! aReg[ nCampo ] $ hGrupo
         AAdd( aLista, { aReg[ nCampo ], 0, 0, 0 } )
         hGrupo[ aReg[ nCampo ] ] := ATail( aLista )
      ENDIF
      hGrupo[ aReg[ nCampo ] ][ G_VALOR ] += aReg[ D_VALOR ]
      hGrupo[ aReg[ nCampo ] ][ G_CUSTO ] += aReg[ D_CUSTO ]
      hGrupo[ aReg[ nCampo ] ][ G_QTD ]   += 1
   NEXT
   ASort( aLista, , , { | a, b | a[ G_VALOR ] > b[ G_VALOR ] } )

   RETURN aLista

/* { valor, custo, pedidos, clientes } */
STATIC FUNCTION Soma( aRegs )

   LOCAL aReg, aSoma := { 0, 0, 0, 0 }, hCli := { => }

   FOR EACH aReg IN aRegs
      aSoma[ 1 ] += aReg[ D_VALOR ]
      aSoma[ 2 ] += aReg[ D_CUSTO ]
      aSoma[ 3 ] += 1
      hCli[ aReg[ D_CLI ] ] := NIL
   NEXT
   aSoma[ 4 ] := Len( hCli )

   RETURN aSoma

/* ---------------------------------------------------------------- tela */

STATIC FUNCTION SincCombos()

   SincCombo( "ANO", Ltrim( Str( s_hF[ "ANO" ] ) ) )
   SincCombo( "VEND", iif( Empty( s_hF[ "VEND" ] ), TODOS, s_hF[ "VEND" ] ) )
   SincCombo( "UF", iif( Empty( s_hF[ "UF" ] ), TODOS, s_hF[ "UF" ] ) )
   SincCombo( "GRUPO", iif( Empty( s_hF[ "GRUPO" ] ), TODOS, s_hF[ "GRUPO" ] ) )

   RETURN NIL

STATIC FUNCTION SincCombo( cNome, cValor )

   LOCAL oCbx := s_hCbx[ cNome ]

   IF ! Eval( oCbx:bSetGet ) == cValor
      Eval( oCbx:bSetGet, cValor )
      oCbx:Set( cValor )
   ENDIF

   RETURN NIL

STATIC FUNCTION MostraFiltro()

   LOCAL cTexto := "", nAno := s_hF[ "ANO" ]

   IF s_hF[ "MES" ] != 0
      cTexto += "Mês: " + NomeMes( s_hF[ "MES" ] ) + "    "
   ENDIF
   IF ! Empty( s_hF[ "VEND" ] )
      cTexto += "Vendedor: " + s_hF[ "VEND" ] + "    "
   ENDIF
   IF ! Empty( s_hF[ "UF" ] )
      cTexto += "UF: " + s_hF[ "UF" ] + "    "
   ENDIF
   IF ! Empty( s_hF[ "GRUPO" ] )
      cTexto += "Grupo: " + s_hF[ "GRUPO" ] + "    "
   ENDIF
   IF ! Empty( s_hF[ "CLI" ] )
      cTexto += "Cliente: " + s_hF[ "CLI" ] + "    "
   ENDIF
   IF Empty( cTexto )
      cTexto := "Sem filtros. Ano " + Ltrim( Str( nAno ) ) + ;
         iif( hb_HGetDef( s_hUltMes, nAno, 12 ) < 12, " até " + Lower( NomeMes( s_hUltMes[ nAno ] ) ) + ".", "." ) + ;
         "    Clique em barras, fatias ou legenda para filtrar; clique de novo para tirar. Duplo clique no cliente."
   ELSE
      cTexto := "Filtros:    " + cTexto
   ENDIF
   s_oSayFiltro:SetText( cTexto )

   RETURN NIL

/* cartões: atual x mesmos meses do ano anterior */
STATIC FUNCTION GrafKpi()

   LOCAL nId := s_hId[ "KPI" ], aRegs := Filtra(), aMeses := {}, aReg, aAnt := {}, aAt, aAn, nLarg, nRegiao
   LOCAL cAnt := "vs " + Ltrim( Str( s_hF[ "ANO" ] - 1 ) ), aCartao, aCartoes

   FOR EACH aReg IN aRegs
      Junta( aMeses, aReg[ D_MES ] )
   NEXT
   FOR EACH aReg IN Filtra( , s_hF[ "ANO" ] - 1 )
      IF AScan( aMeses, aReg[ D_MES ] ) != 0
         AAdd( aAnt, aReg )
      ENDIF
   NEXT
   aAt := Soma( aRegs )
   aAn := Soma( aAnt )
   aCartoes := { ;
      { "Faturamento",     aAt[ 1 ], aAn[ 1 ], COR_AZUL }, ;
      { "Pedidos",         aAt[ 3 ], aAn[ 3 ], COR_AZUL2 }, ;
      { "Ticket médio",    Divide( aAt[ 1 ], aAt[ 3 ] ), Divide( aAn[ 1 ], aAn[ 3 ] ), COR_LARANJA }, ;
      { "Clientes ativos", aAt[ 4 ], aAn[ 4 ], 0x6B007B }, ;
      { "Margem bruta %",  Margem( aAt[ 1 ], aAt[ 2 ] ), Margem( aAn[ 1 ], aAn[ 2 ] ), COR_ROXO } }

   s_oChart:Reset( nId )
   nLarg := Int( ( s_oChart:GetCtrlWidth( nId ) - 5 ) / Len( aCartoes ) )
   IF nLarg <= 0
      nLarg := Int( ( LARGURA - 2 * MARGEM - 16 - 5 ) / Len( aCartoes ) )
   ENDIF
   FOR EACH aCartao IN aCartoes
      nRegiao := aCartao:__EnumIndex()
      s_oChart:AddRegion( nId, 5 + ( nRegiao - 1 ) * nLarg, 5, nLarg - 5, -5, "", .T. )
      s_oChart:AddCaption( nId, nRegiao, aCartao[ 1 ], RMC_COLOR_TRANSPARENT, COR_TEXTO, 10, .T. )
      IF aCartao[ 3 ] != 0
         s_oChart:AddLegend( nId, nRegiao, cAnt, RMC_LEGEND_ONVLABELS, 0, 0, 0, 0, 0 )
         s_oChart:AddGridlessSeries( nId, nRegiao, { aCartao[ 2 ], aCartao[ 3 ] }, 2, { aCartao[ 4 ] }, 1, RMC_KPICARD, 0, 0, .F., RMC_VLABEL_DEFAULT, RMC_HATCHBRUSH_OFF, 0 )
      ELSE
         s_oChart:AddLegend( nId, nRegiao, "sem ano anterior", RMC_LEGEND_ONVLABELS, 0, 0, 0, 0, 0 )
         s_oChart:AddGridlessSeries( nId, nRegiao, { aCartao[ 2 ] }, 1, { aCartao[ 4 ] }, 1, RMC_KPICARD, 0, 0, .F., RMC_VLABEL_DEFAULT, RMC_HATCHBRUSH_OFF, 0 )
      ENDIF
   NEXT
   s_oChart:Draw( nId )

   RETURN NIL

/* colunas do ano e linha do ano anterior */
STATIC FUNCTION GrafMes()

   LOCAL nId := s_hId[ "MES" ], aVal := Array( 12 ), aAnt := Array( 12 ), aReg, nMes, nMax := 0, cLabels := ""

   AFill( aVal, 0 )
   AFill( aAnt, 0 )
   FOR EACH aReg IN Filtra( "MES" )
      aVal[ aReg[ D_MES ] ] += aReg[ D_VALOR ]
   NEXT
   FOR EACH aReg IN Filtra( "MES", s_hF[ "ANO" ] - 1 )
      aAnt[ aReg[ D_MES ] ] += aReg[ D_VALOR ]
   NEXT
   s_hLista[ "MES" ] := {}
   FOR nMes := 1 TO 12
      nMax := Max( nMax, Max( aVal[ nMes ], aAnt[ nMes ] ) )
      cLabels += iif( nMes == 1, "", "*" ) + NomeMes( nMes )
      AAdd( s_hLista[ "MES" ], nMes )
   NEXT
   nMax := Max( Escala( nMax ), 1 )

   s_oChart:Reset( nId )
   s_oChart:AddRegion( nId, 5, 5, -5, -5, "", .F. )
   s_oChart:AddCaption( nId, 1, "Faturamento por mês", RMC_COLOR_TRANSPARENT, COR_TITULO, 10, .T. )
   s_oChart:AddGrid( nId, 1, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   s_oChart:AddDataAxis( nId, 1, RMC_DATAAXISLEFT, 0, nMax, 5, 8, COR_TEXTO, 0xE1DFDD, RMC_LINESTYLESOLID, 0, "", "", "", RMC_TEXTRIGHT )
   s_oChart:AddLabelAxis( nId, 1, cLabels, 1, 12, RMC_LABELAXISBOTTOM, 8, COR_TEXTO, RMC_TEXTCENTER, 0xE1DFDD, RMC_LINESTYLENONE, "" )
   s_oChart:AddLegend( nId, 1, Ltrim( Str( s_hF[ "ANO" ] ) ) + "*" + Ltrim( Str( s_hF[ "ANO" ] - 1 ) ), ;
      RMC_LEGEND_TOP, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, COR_TEXTO, 8, .F. )
   s_oChart:AddBarSeries( nId, 1, aVal, 12, RMC_BARSINGLE, RMC_BAR_FLAT, .F., COR_AZUL, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   Apaga( nId, 1, 12, COR_AZUL, s_hF[ "MES" ] )
   s_oChart:AddLineSeries( nId, 1, aAnt, 12, 0, 0, RMC_LINE, RMC_LINE_FLAT, RMC_LSTYLE_LINE, .F., COR_LARANJA, RMC_SYMBOL_BULLET_SMALL, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   s_oChart:Draw( nId )

   RETURN NIL

STATIC FUNCTION GrafGrupo()

   LOCAL nId := s_hId[ "GRUPO" ], aLista := Agrupa( Filtra( "GRUPO" ), D_GRUPO ), aItem, aValores := {}, aCores := {}
   LOCAL cLabels := "", nTotal := 0, nCor, aCor := { COR_AZUL, COR_AZUL2, COR_LARANJA, 0x6B007B, 0xE044A7, COR_ROXO, 0xD9B300, 0xD64550 }

   s_hLista[ "GRUPO" ] := {}
   FOR EACH aItem IN aLista
      nTotal += aItem[ G_VALOR ]
   NEXT
   FOR EACH aItem IN aLista
      nCor := aCor[ ( AScan( s_aGrupos, aItem[ G_NOME ] ) - 1 ) % Len( aCor ) + 1 ]
      AAdd( aValores, aItem[ G_VALOR ] )
      AAdd( aCores, iif( Empty( s_hF[ "GRUPO" ] ) .OR. s_hF[ "GRUPO" ] == aItem[ G_NOME ], nCor, Clara( nCor ) ) )
      AAdd( s_hLista[ "GRUPO" ], aItem[ G_NOME ] )
      cLabels += iif( aItem:__EnumIsFirst(), "", "*" ) + StrTran( aItem[ G_NOME ], "*", " " ) + " " + FmtN( Divide( aItem[ G_VALOR ] * 100, nTotal ), 0 ) + "%"
   NEXT

   s_oChart:Reset( nId )
   s_oChart:AddRegion( nId, 5, 5, -5, -5, "", .F. )
   s_oChart:AddCaption( nId, 1, "Faturamento por grupo - total " + FmtC( nTotal ), RMC_COLOR_TRANSPARENT, COR_TITULO, 10, .T. )
   IF ! Empty( aValores )
      s_oChart:AddLegend( nId, 1, cLabels, RMC_LEGEND_RIGHT, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, COR_TITULO, 9, .F. )
      s_oChart:AddGridlessSeries( nId, 1, aValores, Len( aValores ), aCores, Len( aCores ), RMC_DONUT_FLAT, RMC_FULL, 0, .F., RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF, 0 )
   ENDIF
   s_oChart:Draw( nId )

   RETURN NIL

/* barras deitadas por vendedor ou UF */
STATIC FUNCTION GrafBarras( cCampo, cTitulo, nCor )

   LOCAL aLista := Agrupa( Filtra( cCampo ), iif( cCampo == "VEND", D_VEND, D_UF ) ), aValores := {}, aNomes := {}, aItem

   FOR EACH aItem IN aLista
      AAdd( aNomes, aItem[ G_NOME ] )
      AAdd( aValores, aItem[ G_VALOR ] )
   NEXT
   BarrasDeitadas( cCampo, cTitulo, aNomes, aValores, nCor, s_hF[ cCampo ], "" )

   RETURN NIL

STATIC FUNCTION GrafMargem()

   LOCAL aLista := Agrupa( Filtra( "GRUPO" ), D_GRUPO ), aItem, aValores := {}, aNomes := {}

   FOR EACH aItem IN aLista
      aItem[ G_CUSTO ] := Margem( aItem[ G_VALOR ], aItem[ G_CUSTO ] )   // custo vira margem
   NEXT
   ASort( aLista, , , { | a, b | a[ G_CUSTO ] > b[ G_CUSTO ] } )
   FOR EACH aItem IN aLista
      AAdd( aNomes, aItem[ G_NOME ] )
      AAdd( aValores, Round( aItem[ G_CUSTO ], 1 ) )
   NEXT
   BarrasDeitadas( "MARGEM", "Margem por grupo (%)", aNomes, aValores, COR_ROXO, s_hF[ "GRUPO" ], "" )

   RETURN NIL

STATIC FUNCTION BarrasDeitadas( cGrafico, cTitulo, aNomes, aValores, nCor, cEscolhido, cUnidade )

   LOCAL nId := s_hId[ cGrafico ], cLabels := "", cNome, nMax := 0, nValor

   FOR EACH cNome IN aNomes
      cLabels += iif( cNome:__EnumIsFirst(), "", "*" ) + StrTran( cNome, "*", " " )
   NEXT
   FOR EACH nValor IN aValores
      nMax := Max( nMax, nValor )
   NEXT
   s_hLista[ cGrafico ] := AClone( aNomes )

   s_oChart:Reset( nId )
   s_oChart:AddRegion( nId, 5, 5, -5, -5, "", .F. )
   s_oChart:AddCaption( nId, 1, cTitulo, RMC_COLOR_TRANSPARENT, COR_TITULO, 10, .T. )
   IF ! Empty( aValores )
      s_oChart:AddGrid( nId, 1, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
      s_oChart:AddDataAxis( nId, 1, RMC_DATAAXISBOTTOM, 0, Max( Escala( nMax * 1.15 ), 1 ), 5, 8, COR_TEXTO, 0xE1DFDD, RMC_LINESTYLESOLID, 0, cUnidade, "", "", RMC_TEXTCENTER )
      s_oChart:AddLabelAxis( nId, 1, cLabels, 1, Len( aNomes ), RMC_LABELAXISLEFT, 9, COR_TITULO, RMC_TEXTRIGHT, 0xE1DFDD, RMC_LINESTYLENONE, "" )
      s_oChart:AddBarSeries( nId, 1, aValores, Len( aValores ), RMC_BARSINGLE, RMC_BAR_FLAT, .F., nCor, .T., 1, RMC_VLABEL_DEFAULT, 1, RMC_HATCHBRUSH_OFF )
      Apaga( nId, 1, Len( aNomes ), nCor, AScan( aNomes, { | c | c == cEscolhido } ) )
   ENDIF
   s_oChart:Draw( nId )

   RETURN NIL

/* com um escolhido, as outras barras da série 1 ficam claras */
STATIC FUNCTION Apaga( nId, nRegiao, nQtd, nCor, nEscolhido )

   LOCAL nPos

   IF nEscolhido > 0
      FOR nPos := 1 TO nQtd
         IF nPos != nEscolhido
            s_oChart:SetSeriesColor( nId, nRegiao, 1, Clara( nCor ), nPos )
         ENDIF
      NEXT
   ENDIF

   RETURN NIL

STATIC FUNCTION TabClientes()

   LOCAL aLista := Agrupa( Filtra( "CLI" ), D_CLI ), aItem

   ASize( s_aTop, 0 )
   FOR EACH aItem IN aLista
      AAdd( s_aTop, { aItem[ G_NOME ], aItem[ G_VALOR ], aItem[ G_QTD ], Divide( aItem[ G_VALOR ], aItem[ G_QTD ] ), Margem( aItem[ G_VALOR ], aItem[ G_CUSTO ] ) } )
      IF Len( s_aTop ) == 10
         EXIT
      ENDIF
   NEXT
   IF Empty( s_aTop )
      AAdd( s_aTop, { "Sem dados para o filtro.", 0, 0, 0, 0 } )
   ENDIF
   s_oBrw:GoTop()
   s_oBrw:Refresh()

   RETURN NIL

/* ---------------------------------------------------------------- auxiliares */

STATIC FUNCTION AnosTexto()

   LOCAL aLista := {}, nAno

   FOR EACH nAno IN s_aAnos
      AAdd( aLista, Ltrim( Str( nAno ) ) )
   NEXT

   RETURN aLista

STATIC FUNCTION ComTodos( aLista )

   LOCAL aNova := AClone( aLista )

   ASort( aNova )
   hb_AIns( aNova, 1, TODOS, .T. )

   RETURN aNova

STATIC FUNCTION NomeMes( nMes )

   RETURN { "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez" }[ nMes ]

STATIC FUNCTION Divide( nValor, nPor )

   RETURN iif( nPor == 0, 0, nValor / nPor )

STATIC FUNCTION Margem( nValor, nCusto )

   RETURN iif( nValor == 0, 0, ( nValor - nCusto ) / nValor * 100 )

STATIC FUNCTION FmtN( nValor, nDecimais )

   RETURN AllTrim( Transform( nValor, "@E 999,999,999,999" + iif( nDecimais > 0, "." + Replicate( "9", nDecimais ), "" ) ) )

STATIC FUNCTION FmtC( nValor )

   DO CASE
   CASE Abs( nValor ) >= 1000000 ; RETURN FmtN( nValor / 1000000, 2 ) + " mi"
   CASE Abs( nValor ) >= 1000    ; RETURN FmtN( nValor / 1000, 0 ) + " mil"
   ENDCASE

   RETURN FmtN( nValor, 0 )

/* cor RRGGBB misturada com 70% de branco */
STATIC FUNCTION Clara( nCor )

   LOCAL nR := hb_BitAnd( hb_BitShift( nCor, -16 ), 0xFF ), nG := hb_BitAnd( hb_BitShift( nCor, -8 ), 0xFF ), nB := hb_BitAnd( nCor, 0xFF )

   nR := Int( nR + ( 255 - nR ) * 0.7 )
   nG := Int( nG + ( 255 - nG ) * 0.7 )
   nB := Int( nB + ( 255 - nB ) * 0.7 )

   RETURN nR * 65536 + nG * 256 + nB

/* arredonda pra cima num valor redondo, pra escala do eixo (igual ao fwdashboardgrafico) */
STATIC FUNCTION Escala( nValor )

   LOCAL nPotencia, nPasso

   IF nValor <= 0
      RETURN 0
   ENDIF
   nValor    := nValor * 1.05
   nPotencia := 10 ^ Int( Log( nValor ) / Log( 10 ) )
   FOR EACH nPasso IN { 1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10 }
      IF nPasso * nPotencia >= nValor
         RETURN nPasso * nPotencia
      ENDIF
   NEXT

   RETURN 10 * nPotencia
