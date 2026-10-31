/*
TESTWVT - charts on a GTWVT window

hbmk2 testwvt.hbp
*/

#include "ze_rmchart.ch"
#include "hbgtinfo.ch"
#include "inkey.ch"

REQUEST HB_CODEPAGE_PTISO

FUNCTION Main( nSeconds )

   LOCAL oChart := RMChartClass():New(), nBarId, nPieId, hWnd

   hb_cdpSelect( "PTISO" )
   hb_Default( @nSeconds, "0" )
   SetMode( 30, 100 )
   SetColor( "W/B" )
   CLS
   @ 0, 1 SAY "chartclass - ESC to exit"
   hWnd := hb_gtInfo( HB_GTI_WINHANDLE )

   nBarId := oChart:GetChartId()
   oChart:CreateChart( hWnd, nBarId, 10, 30, 380, 420, RMC_COLOR_AZURE, RMC_CTRLSTYLE3DLIGHT, .F., "", "Tahoma", 0, 0 )
   oChart:AddRegion( nBarId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nBarId, 1, "Bars", RMC_COLOR_BLUE, RMC_COLOR_YELLOW, 11, .T. )
   oChart:AddGrid( nBarId, 1, RMC_COLOR_BEIGE, .F., 0, 0, 0, 0, RMC_BICOLOR_LABELAXIS )
   oChart:AddDataAxis( nBarId, 1, RMC_DATAAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nBarId, 1, "Jan*Feb*Mar*Apr*May", 1, 5, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddLegend( nBarId, 1, "2025*2026", RMC_LEGEND_TOP, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddBarSeries( nBarId, 1, { 60, 70, 40, 60, 30 }, 5, RMC_BARGROUP, RMC_BAR_FLAT_GRADIENT2, .F., RMC_COLOR_DEFAULT, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oChart:AddBarSeries( nBarId, 1, { 50, 80, 45, 70, 55 }, 5, RMC_BARGROUP, RMC_BAR_FLAT_GRADIENT2, .F., RMC_COLOR_DEFAULT, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oChart:Draw( nBarId )
   oChart:Reset( nBarId )

   nPieId := oChart:GetChartId()
   oChart:CreateChart( hWnd, nPieId, 400, 30, 380, 420, RMC_COLOR_WHITE, RMC_CTRLSTYLE3DLIGHT, .F., "", "Tahoma", 0, 0 )
   oChart:AddRegion( nPieId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nPieId, 1, "Donut 3D", RMC_COLOR_STEEL_BLUE, RMC_COLOR_WHITE, 11, .T. )
   oChart:AddLegend( nPieId, 1, "Water*Light*Phone*Food", RMC_LEGEND_BOTTOM, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddGridlessSeries( nPieId, 1, { 30, 50, 20, 40 }, 4, 0, 0, RMC_DONUT_3D_GRADIENT, RMC_FULL, RMC_EXPLODE_BIGGEST, .F., RMC_VLABEL_PERCENT, RMC_HATCHBRUSH_OFF, 0 )
   oChart:Draw( nPieId )
   oChart:Reset( nPieId )

   IF Val( nSeconds ) > 0
      Inkey( Val( nSeconds ) )
   ELSE
      DO WHILE Inkey( 0 ) != K_ESC
      ENDDO
   ENDIF
   oChart:DeleteChart( nBarId )
   oChart:DeleteChart( nPieId )

   RETURN NIL
