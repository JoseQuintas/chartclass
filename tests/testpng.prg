/*
TESTPNG - charts saved to PNG files, without window
Same source compiles with rmchartclass (rmchart.dll), to compare

hbmk2 testpng.hbp
*/

#include "ze_rmchart.ch"

REQUEST HB_CODEPAGE_PTISO

#define CHART_WIDTH  700
#define CHART_HEIGHT 480

#ifdef USE_DLL
   #include "hbgtinfo.ch"
#endif

STATIC s_hParent := 0

FUNCTION Main( cPrefix )

   hb_cdpSelect( "PTISO" )
   hb_Default( @cPrefix, "chart" )
#ifdef USE_DLL
   // rmchart.dll needs a parent window, even to export only
   CLS
   s_hParent := hb_gtInfo( HB_GTI_WINHANDLE )
#endif

   ? "bars grouped", ChartGroup( cPrefix + "_01_group.png" )
   ? "bars single",  ChartSingle( cPrefix + "_02_single.png" )
   ? "bars stacked", ChartStacked( cPrefix + "_03_stacked.png" )
   ? "bars 3D",      ChartBar3D( cPrefix + "_04_bar3d.png" )
   ? "pie",          ChartPie( cPrefix + "_05_pie.png" )
   ? "pie 3D",       ChartPie3D( cPrefix + "_06_pie3d.png" )
   ? "donut",        ChartDonut( cPrefix + "_07_donut.png" )
   ? "four regions", ChartFour( cPrefix + "_08_four.png" )
   ? "half pie",     ChartHalfPie( cPrefix + "_09_halfpie.png" )
   ? "lines",        ChartLines( cPrefix + "_10_lines.png" )
   ? "areas",        ChartAreas( cPrefix + "_11_areas.png" )
   ? "area stacked", ChartAreaStacked( cPrefix + "_12_areastacked.png" )
   ? "bar and line", ChartBarLine( cPrefix + "_13_barline.png" )
   ? "3D and stair", ChartLine3D( cPrefix + "_14_line3d.png" )
   ? "xy",           ChartXY( cPrefix + "_15_xy.png" )
   ? "candlestick",  ChartHighLow( cPrefix + "_16_candle.png", RMC_CANDLESTICK )
   ? "ohlc",         ChartHighLow( cPrefix + "_17_ohlc.png", RMC_OHLC )
   ? "pyramid",      ChartPyramid( cPrefix + "_18_pyramid.png" )
   ? "floating",     ChartFloating( cPrefix + "_19_floating.png" )
   ? "indexed",      ChartIndexed( cPrefix + "_20_indexed.png" )

   RETURN NIL

STATIC FUNCTION ChartFloating( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "Floating bars: planned and done (start, length)", RMC_COLOR_STEEL_BLUE, RMC_COLOR_WHITE, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_LABELAXIS )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISBOTTOM, 0, 30, 7, 8, RMC_COLOR_BLACK, RMC_COLOR_SILVER, RMC_LINESTYLEDOT, 0, "", "Days", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "Analysis*Design*Coding*Tests*Delivery", 1, 5, RMC_LABELAXISLEFT, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddLegend( nChartId, 1, "Planned*Done", RMC_LEGEND_BOTTOM, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddBarSeries( nChartId, 1, { 0, 5, 5, 6, 10, 12, 20, 5, 25, 3 }, 10, RMC_FLOATINGBARGROUP, RMC_BAR_FLAT_GRADIENT2, .F., RMC_COLOR_CORN_FLOWER_BLUE, .T., 1, RMC_VLABEL_DEFAULT, 1, RMC_HATCHBRUSH_OFF )
   oChart:AddBarSeries( nChartId, 1, { 0, 6, 6, 8, 13, 13, 24, 4, 28, 2 }, 10, RMC_FLOATINGBARGROUP, RMC_BAR_FLAT_GRADIENT2, .F., RMC_COLOR_DARK_GREEN, .T., 1, RMC_VLABEL_DEFAULT, 1, RMC_HATCHBRUSH_OFF )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartIndexed( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "Indexed: first value = 100", RMC_COLOR_STEEL_BLUE, RMC_COLOR_WHITE, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 80, 130, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_SILVER, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "Jan*Feb*Mar*Apr*May*Jun", 1, 6, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddLegend( nChartId, 1, "Index A (10.000 points)*Index B (2.000 points)", RMC_LEGEND_BOTTOM, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddLineSeries( nChartId, 1, { 10000, 10400, 10200, 11000, 11500, 11200 }, 6, 0, 0, RMC_AREA_INDEXED, RMC_AREA_FLAT, RMC_LSTYLE_LINE, .T., RMC_COLOR_CORN_FLOWER_BLUE, RMC_SYMBOL_NONE, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, { 2000, 1900, 2100, 2300, 2250, 2500 }, 6, 0, 0, RMC_LINE_INDEXED, RMC_LINE_FLAT, RMC_LSTYLE_LINE, .F., RMC_COLOR_CRIMSON, RMC_SYMBOL_ROUND, 1, RMC_VLABEL_DEFAULT, RMC_HATCHBRUSH_OFF )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartXY( cFile )

   LOCAL nChartId, oChart := RMChartClass():New(), nCont
   LOCAL aX1 := {}, aY1 := {}, aX2 := {}, aY2 := {}

   FOR nCont = 0 TO 40
      AAdd( aX1, nCont / 2 )
      AAdd( aY1, 50 + 40 * Sin( nCont / 4 ) )
   NEXT
   FOR nCont = 1 TO 12
      AAdd( aX2, nCont * 1.6 )
      AAdd( aY2, 10 + ( nCont * 37 ) % 70 )
   NEXT

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "XY series", RMC_COLOR_STEEL_BLUE, RMC_COLOR_WHITE, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddXAxis( nChartId, 1, RMC_XAXISBOTTOM, 0, 20, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_SILVER, RMC_LINESTYLEDOT, 1, "", "X axis", "", RMC_TEXTCENTER )
   oChart:AddYAxis( nChartId, 1, RMC_YAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_SILVER, RMC_LINESTYLEDOT, 0, "", "Y axis", "", RMC_TEXTCENTER )
   oChart:AddLegend( nChartId, 1, "Sine*Points", RMC_LEGEND_BOTTOM, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddXYSeries( nChartId, 1, aX1, Len( aX1 ), aY1, Len( aY1 ), RMC_COLOR_DEFAULT, RMC_XY_CABLE, RMC_LSTYLE_SPLINE, RMC_SYMBOL_NONE, RMC_XAXISBOTTOM, RMC_YAXISLEFT, RMC_VLABEL_NONE )
   oChart:AddXYSeries( nChartId, 1, aX2, Len( aX2 ), aY2, Len( aY2 ), RMC_COLOR_CRIMSON, RMC_XY_SYMBOL, RMC_LSTYLE_LINE, RMC_SYMBOL_DIAMOND, RMC_XAXISBOTTOM, RMC_YAXISLEFT, RMC_VLABEL_DEFAULT )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartHighLow( cFile, nStyle )

   LOCAL nChartId, oChart := RMChartClass():New(), nCont, nOpen, nClose, nHigh, nLow
   LOCAL aData := {}, aVolume := {}, nPrice := 50

   FOR nCont = 1 TO 20
      nOpen  := nPrice
      nClose := nPrice + ( ( nCont * 7 ) % 11 ) - 5
      nHigh  := Max( nOpen, nClose ) + ( nCont % 3 ) + 1
      nLow   := Min( nOpen, nClose ) - ( nCont % 4 ) - 1
      AAdd( aData, nOpen )
      AAdd( aData, nHigh )
      AAdd( aData, nLow )
      AAdd( aData, nClose )
      AAdd( aVolume, 1000 + ( nCont * 373 ) % 2000 )
      nPrice := nClose
   NEXT

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )

   oChart:AddRegion( nChartId, 5, 5, -5, 330, "", .F. )
   oChart:AddCaption( nChartId, 1, iif( nStyle == RMC_CANDLESTICK, "Candlestick", "OHLC" ), RMC_COLOR_STEEL_BLUE, RMC_COLOR_WHITE, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_LABELAXIS )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISRIGHT, 30, 70, 9, 8, RMC_COLOR_BLACK, RMC_COLOR_SILVER, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "Week 1*Week 2*Week 3*Week 4", 1, 4, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_SILVER, RMC_LINESTYLESOLID, "" )
   oChart:AddHighLowSeries( nChartId, 1, aData, Len( aData ), { 5 }, 1, nStyle, 1, 0, 0 )

   oChart:AddRegion( nChartId, 5, 335, -5, -5, "", .F. )
   oChart:AddGrid( nChartId, 2, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_LABELAXIS )
   oChart:AddDataAxis( nChartId, 2, RMC_DATAAXISRIGHT, 0, 3000, 4, 8, RMC_COLOR_BLACK, RMC_COLOR_SILVER, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 2, "Week 1*Week 2*Week 3*Week 4", 1, 4, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_SILVER, RMC_LINESTYLESOLID, "" )
   oChart:AddVolumeBarSeries( nChartId, 2, aVolume, Len( aVolume ), { 5 }, 1, RMC_COLOR_NAVY, 1 )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartPyramid( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()
   LOCAL nW := Int( CHART_WIDTH / 2 )

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )

   oChart:AddRegion( nChartId, 5, 5, nW - 10, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "Pyramid", RMC_COLOR_TRANSPARENT, RMC_COLOR_BLACK, 10, .T. )
   oChart:AddLegend( nChartId, 1, "Visitors*Leads*Offers*Orders", RMC_LEGEND_BOTTOM, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddGridlessSeries( nChartId, 1, { 50, 30, 15, 5 }, 4, 0, 0, RMC_PYRAMIDE, RMC_FULL, 0, .F., RMC_VLABEL_DEFAULT, RMC_HATCHBRUSH_OFF, 0 )

   oChart:AddRegion( nChartId, nW + 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 2, "Pyramid 3D", RMC_COLOR_TRANSPARENT, RMC_COLOR_BLACK, 10, .T. )
   oChart:AddLegend( nChartId, 2, "Visitors*Leads*Offers*Orders", RMC_LEGEND_BOTTOM, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddGridlessSeries( nChartId, 2, { 50, 30, 15, 5 }, 4, 0, 0, RMC_PYRAMIDE3, RMC_FULL, 0, .F., RMC_VLABEL_PERCENT, RMC_HATCHBRUSH_OFF, 0 )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartLines( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "Lines: flat, cable, spline, dash", RMC_COLOR_STEEL_BLUE, RMC_COLOR_WHITE, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_SILVER, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "Jan*Feb*Mar*Apr*May*Jun*Jul*Aug", 1, 8, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddLegend( nChartId, 1, "Flat*Cable shadow*Spline*Dash", RMC_LEGEND_BOTTOM, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddLineSeries( nChartId, 1, { 20, 35, 30, 50, 45, 60, 55, 70 }, 8, 0, 0, RMC_LINE, RMC_LINE_FLAT, RMC_LSTYLE_LINE, .F., RMC_COLOR_DEFAULT, RMC_SYMBOL_ROUND, 1, RMC_VLABEL_DEFAULT, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, { 40, 30, 45, 35, 60, 50, 75, 65 }, 8, 0, 0, RMC_LINE, RMC_LINE_CABLE_SHADOW, RMC_LSTYLE_LINE, .F., RMC_COLOR_DEFAULT, RMC_SYMBOL_BULLET, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, { 10, 15, 25, 20, 30, 25, 35, 40 }, 8, 0, 0, RMC_LINE, RMC_LINE_FLAT, RMC_LSTYLE_SPLINE, .F., RMC_COLOR_DEFAULT, RMC_SYMBOL_DIAMOND, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, { 80, 85, 75, 90, 80, 85, 90, 95 }, 8, 0, 0, RMC_LINE, RMC_LINE_FLAT_DASH, RMC_LSTYLE_LINE, .F., RMC_COLOR_DEFAULT, RMC_SYMBOL_STAR_SMALL, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartAreas( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_ALICE_BLUE, RMC_CTRLSTYLEFLATSHADOW, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "Areas: gradient, lucent, line with area", RMC_COLOR_TRANSPARENT, RMC_COLOR_NAVY, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_DATAAXIS )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 0, 6, 8, RMC_COLOR_BLACK, RMC_COLOR_SILVER, RMC_LINESTYLESOLID, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "2019*2020*2021*2022*2023*2024*2025", 1, 7, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddLegend( nChartId, 1, "Gradient*Lucent*Line with area", RMC_LEGEND_CUSTOM_UL, RMC_COLOR_WHITE, RMC_LEGENDROUNDRECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddLineSeries( nChartId, 1, { 300, 450, 400, 600, 550, 700, 650 }, 7, 0, 0, RMC_AREA, RMC_AREA_FLAT_GRADIENT_V, RMC_LSTYLE_LINE, .F., RMC_COLOR_CORN_FLOWER_BLUE, RMC_SYMBOL_NONE, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, { 150, 250, 350, 300, 400, 350, 450 }, 7, 0, 0, RMC_AREA, RMC_AREA_FLAT, RMC_LSTYLE_SPLINE, .T., RMC_COLOR_ORANGE, RMC_SYMBOL_NONE, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, { 100, 120, 200, 150, 220, 180, 260 }, 7, 0, 0, RMC_LINE, RMC_LINE_FLAT, RMC_LSTYLE_LINE_AREA, .F., RMC_COLOR_DARK_GREEN, RMC_SYMBOL_CIRCLE, 1, RMC_VLABEL_DEFAULT, RMC_HATCHBRUSH_OFF )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartAreaStacked( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "Stacked areas", RMC_COLOR_DARK_SLATE_GRAY, RMC_COLOR_WHITE, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 0, 6, 8, RMC_COLOR_BLACK, RMC_COLOR_SILVER, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "Q1*Q2*Q3*Q4*Q5*Q6", 1, 6, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddLegend( nChartId, 1, "North*South*East", RMC_LEGEND_RIGHT, RMC_COLOR_DEFAULT, RMC_LEGENDRECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddLineSeries( nChartId, 1, { 20, 25, 30, 28, 35, 40 }, 6, 0, 0, RMC_AREA_STACKED, RMC_AREA_FLAT, RMC_LSTYLE_LINE, .F., RMC_COLOR_DEFAULT, RMC_SYMBOL_NONE, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, { 15, 18, 12, 20, 22, 18 }, 6, 0, 0, RMC_AREA_STACKED, RMC_AREA_FLAT, RMC_LSTYLE_LINE, .F., RMC_COLOR_DEFAULT, RMC_SYMBOL_NONE, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, { 10, 12, 18, 15, 10, 20 }, 6, 0, 0, RMC_AREA_STACKED, RMC_AREA_FLAT, RMC_LSTYLE_LINE, .F., RMC_COLOR_DEFAULT, RMC_SYMBOL_NONE, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartBarLine( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_ALICE_BLUE, RMC_CTRLSTYLEFLAT, .T., "", "", 0, 0 )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "Bars on axis 1, line on axis 2", RMC_COLOR_TRANSPARENT, RMC_COLOR_BLACK, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_ALICE_BLUE, .T., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 250, 11, 8, RMC_COLOR_BLUE, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, 0, "$", "DATAAXIS 1", "", RMC_TEXTCENTER )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISRIGHT, 0, 50, 11, 8, RMC_COLOR_GREEN, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, 0, "", "DATAAXIS 2", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "", 1, 10, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, "LABELAXIS" )
   oChart:AddBarSeries( nChartId, 1, { 240, 230, 220, 180, 170, 160, 145, 130, 125, 115 }, 10, RMC_BARSINGLE, RMC_BAR_FLAT_GRADIENT2, .F., RMC_COLOR_GOLD, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, { 5, 7, 8, 18, 25, 32, 35, 38, 42, 45 }, 10, 0, 0, RMC_LINE, RMC_LINE_CABLE, RMC_LSTYLE_LINE, .F., RMC_COLOR_GREEN, RMC_SYMBOL_NONE, 2, RMC_VLABEL_DEFAULT, RMC_HATCHBRUSH_OFF )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartLine3D( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()
   LOCAL nW := Int( CHART_WIDTH / 2 )

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_BISQUE, RMC_CTRLSTYLE3DLIGHT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )

   oChart:AddRegion( nChartId, 5, 5, nW - 10, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "3D area and 3D line", RMC_COLOR_BISQUE, RMC_COLOR_BLACK, 10, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_CORN_SILK, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "A*B*C*D*E*F", 1, 6, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddLineSeries( nChartId, 1, { 30, 50, 40, 70, 60, 80 }, 6, 0, 0, RMC_AREA, RMC_AREA_3D_GRADIENT_V, RMC_LSTYLE_LINE, .F., RMC_COLOR_DARK_GREEN, RMC_SYMBOL_NONE, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, { 10, 25, 20, 35, 30, 45 }, 6, 0, 0, RMC_LINE, RMC_LINE_3D_GRADIENT, RMC_LSTYLE_LINE, .F., RMC_COLOR_MAROON, RMC_SYMBOL_NONE, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )

   oChart:AddRegion( nChartId, nW + 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 2, "Stair and symbols only", RMC_COLOR_BISQUE, RMC_COLOR_BLACK, 10, .T. )
   oChart:AddGrid( nChartId, 2, RMC_COLOR_CORN_SILK, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 2, RMC_DATAAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 2, "A*B*C*D*E*F", 1, 6, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddLineSeries( nChartId, 2, { 20, 40, 35, 60, 55, 75 }, 6, 0, 0, RMC_LINE, RMC_LINE_FLAT, RMC_LSTYLE_STAIR_AREA, .F., RMC_COLOR_NAVY, RMC_SYMBOL_NONE, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 2, { 85, 70, 90, 80, 95, 88 }, 6, 0, 0, RMC_LINE, RMC_LINE_SYMBOLONLY, RMC_LSTYLE_LINE, .F., RMC_COLOR_CRIMSON, RMC_SYMBOL_SQUARE, 1, RMC_VLABEL_DEFAULT, RMC_HATCHBRUSH_OFF )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartGroup( cFile )

   LOCAL nChartId, oChart := RMChartClass():New(), nCont
   LOCAL aData := { ;
      { 225.25, 100.00, 100.00, 150.00, 250.00, 300.00, 25.00, 75.00, 300.00, 200.00, 325.00, 300.00 }, ;
      { 220.00, 100.00, 125.00, 300.00, 150.00, 125.00, 85.00, 50.00, 285.00, 275.00, 295.00, 280.00 }, ;
      { 125.25, 100.00, 100.00, 150.00, 250.00, 300.00, 25.00, 75.00, 300.00, 200.00, 325.00, 300.00 } }

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_AZURE, RMC_CTRLSTYLE3DLIGHT, .T., "", "", 0, 0 )
   oChart:AddRegion( nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, "chartclass", .F. )
   oChart:AddCaption( nChartId, 1, "Grouped bars", RMC_COLOR_TRANSPARENT, RMC_COLOR_RED, 9, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_LIGHT_BLUE, .F., 0, 0, 0, 0, RMC_BICOLOR_LABELAXIS )
   oChart:AddLabelAxis( nChartId, 1, "Jan*Feb*Mar*Apr*May*Jun*Jul*Aug*Sep*Oct*Nov*Dec", 1, 12, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISRIGHT, 0.0, 330.0, 12, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, 1, "R$ ", "", "", RMC_TEXTCENTER )
   oChart:AddLegend( nChartId, 1, "Income*Outcome*Other", RMC_LEGEND_BOTTOM, RMC_COLOR_TRANSPARENT, RMC_LEGENDNORECT, RMC_COLOR_RED, 8, .T. )
   FOR nCont = 1 TO Len( aData )
      oChart:AddBarSeries( nChartId, 1, aData[ nCont ], 12, RMC_BARGROUP, RMC_BAR_FLAT_GRADIENT2, .F., 0, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   NEXT

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartSingle( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_AZURE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "This is the chart's caption", RMC_COLOR_BLUE, RMC_COLOR_YELLOW, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_BEIGE, .F., 0, 0, 0, 0, RMC_BICOLOR_LABELAXIS )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "Label 1*Label 2*Label 3*Label 4*Label 5", 1, 5, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddBarSeries( nChartId, 1, { 60, 70, 40, 60, 30 }, 5, RMC_BARSINGLE, RMC_BAR_FLAT_GRADIENT2, .F., RMC_COLOR_CORN_FLOWER_BLUE, .F., 1, RMC_VLABEL_DEFAULT, 1, RMC_HATCHBRUSH_OFF )
   oChart:SetSeriesColor( nChartId, 1, 1, RMC_COLOR_RED, 3 )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartStacked( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_BISQUE, RMC_CTRLSTYLE3DLIGHT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "this is the footer", .F. )
   oChart:AddCaption( nChartId, 1, "Example of stacked bars", RMC_COLOR_BISQUE, RMC_COLOR_BLACK, 11, .F. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_CORN_SILK, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 50000, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, 0, "€ ", "optional axis text, 9 points bold\9b", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "Label Nr. 1*Label Nr. 2*Label Nr. 3*Label Nr. 4*Label Nr. 5*Label Nr. 6", 1, 6, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, "optional label axis text" )
   oChart:AddLegend( nChartId, 1, "Apples*Pears*Cherries*Strawberries", RMC_LEGEND_CUSTOM_UL, RMC_COLOR_LIGHT_YELLOW, RMC_LEGENDRECT, RMC_COLOR_BLUE, 8, .F. )
   oChart:AddBarSeries( nChartId, 1, { 10000, 10000, 16000, 12000, 20000, 10000 }, 6, RMC_BARSTACKED, RMC_COLUMN_FLAT, .F., RMC_COLOR_DARK_BLUE, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oChart:AddBarSeries( nChartId, 1, { 5000, 7000, 4000, 15000, 10000, 10000 }, 6, RMC_BARSTACKED, RMC_COLUMN_FLAT, .F., RMC_COLOR_DARK_GREEN, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oChart:AddBarSeries( nChartId, 1, { 10000, 3000, 12000, 10000, 5000, 20000 }, 6, RMC_BARSTACKED, RMC_COLUMN_FLAT, .F., RMC_COLOR_MAROON, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oChart:AddBarSeries( nChartId, 1, { 5000, 9000, 12000, 6000, 10000, 5000 }, 6, RMC_BARSTACKED, RMC_COLUMN_FLAT, .F., RMC_COLOR_DARK_GOLDENROD, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartBar3D( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_BISQUE, RMC_CTRLSTYLE3DLIGHT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "3D bars with value labels", RMC_COLOR_BISQUE, RMC_COLOR_BLACK, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_CORN_SILK, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "North*South*East*West*Center", 1, 5, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, "" )
   oChart:AddBarSeries( nChartId, 1, { 25, 40, 35, 60, 45 }, 5, RMC_BARSINGLE, RMC_BAR_3D, .F., RMC_COLOR_DARK_GREEN, .F., 1, RMC_VLABEL_DEFAULT, 1, RMC_HATCHBRUSH_OFF )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartPie( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "Pie with gradient", RMC_COLOR_STEEL_BLUE, RMC_COLOR_WHITE, 11, .T. )
   oChart:AddLegend( nChartId, 1, "Water*Light*Phone*Food*Taxes", RMC_LEGEND_RIGHT, RMC_COLOR_DEFAULT, RMC_LEGENDRECTSHADOW, RMC_COLOR_DEFAULT, 9, .F. )
   oChart:AddGridlessSeries( nChartId, 1, { 30, 50, 20, 40, 60 }, 5, 0, 0, RMC_PIE_GRADIENT, RMC_FULL, 0, .F., RMC_VLABEL_PERCENT, RMC_HATCHBRUSH_OFF, 0 )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartPie3D( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_ALICE_BLUE, RMC_CTRLSTYLEFLATSHADOW, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "3D pie, slice 2 exploded, legend on labels", RMC_COLOR_TRANSPARENT, RMC_COLOR_NAVY, 11, .T. )
   oChart:AddLegend( nChartId, 1, "Water*Light*Phone*Food*Taxes", RMC_LEGEND_ONVLABELS, 0, 0, 0, 0, 0 )
   oChart:AddGridlessSeries( nChartId, 1, { 30, 50, 20, 40, 60 }, 5, 0, 0, RMC_PIE_3D_GRADIENT, RMC_FULL, 2, .F., RMC_VLABEL_DEFAULT, RMC_HATCHBRUSH_OFF, 0 )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartDonut( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()
   LOCAL aColors := { RMC_COLOR_LIGHT_GREEN, RMC_COLOR_YELLOW, RMC_COLOR_GOLDENROD, RMC_COLOR_CRIMSON }

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_MIDNIGHT_BLUE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddLegend( nChartId, 1, "Apples*Citrons*Bananas*Cherries", RMC_LEGEND_CUSTOM_CENTER, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, RMC_COLOR_WHITE, 8, .F. )
   oChart:AddGridlessSeries( nChartId, 1, { 40, 30, 60, 20 }, 4, aColors, 4, RMC_DONUT_GRADIENT, RMC_FULL, 0, .F., RMC_VLABEL_TWIN, RMC_HATCHBRUSH_OFF, 0 )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartFour( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()
   LOCAL nW := Int( CHART_WIDTH / 2 ), nH := Int( CHART_HEIGHT / 2 )

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_ALICE_BLUE, RMC_CTRLSTYLEFLATSHADOW, .T., "", "", 0, 0 )

   oChart:AddRegion( nChartId, 0, 0, nW - 5, nH - 5, "", .F. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_BEIGE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, 0, "", "DATAAXIS1", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "Label 1*Label 2*Label 3*Label 4*Label 5", 1, 5, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, "LABELAXIS1" )
   oChart:AddBarSeries( nChartId, 1, { 30, 40, 70, 60, 20 }, 5, RMC_BARSINGLE, RMC_BAR_3D, .F., RMC_COLOR_DEFAULT, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )

   oChart:AddRegion( nChartId, nW + 1, 0, nW - 5, nH - 5, "", .F. )
   oChart:AddGrid( nChartId, 2, RMC_COLOR_BEIGE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 2, RMC_DATAAXISTOP, 0, 100, 10, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, 0, "", "DATAAXIS2", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 2, "Label 1*Label 2*Label 3*Label 4*Label 5", 1, 5, RMC_LABELAXISLEFT, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, "LABELAXIS2" )
   oChart:AddBarSeries( nChartId, 2, { 20, 10, 15, 25, 30 }, 5, RMC_BARSTACKED, RMC_COLUMN_FLAT, .F., RMC_COLOR_DEFAULT, .T., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oChart:AddBarSeries( nChartId, 2, { 25, 30, 10, 20, 15 }, 5, RMC_BARSTACKED, RMC_COLUMN_FLAT, .F., RMC_COLOR_DEFAULT, .T., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oChart:AddBarSeries( nChartId, 2, { 10, 20, 40, 20, 30 }, 5, RMC_BARSTACKED, RMC_COLUMN_FLAT, .F., RMC_COLOR_DEFAULT, .T., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oChart:AddBarSeries( nChartId, 2, { 40, 30, 20, 30, 20 }, 5, RMC_BARSTACKED, RMC_COLUMN_FLAT, .F., RMC_COLOR_DEFAULT, .T., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )

   oChart:AddRegion( nChartId, 0, nH + 1, nW - 5, nH - 5, "", .F. )
   oChart:AddLegend( nChartId, 3, "WATER*LIGHT*PHONE*FOOD*TAXES", RMC_LEGEND_ONVLABELS, 0, 0, 0, 0, 0 )
   oChart:AddGridlessSeries( nChartId, 3, { 30, 50, 20, 40, 60 }, 5, 0, 0, RMC_PIE_3D_GRADIENT, RMC_FULL, 2, .F., RMC_VLABEL_DEFAULT, RMC_HATCHBRUSH_OFF, 0 )

   oChart:AddRegion( nChartId, nW + 1, nH + 1, nW - 5, nH - 5, "", .F. )
   oChart:AddGrid( nChartId, 4, RMC_COLOR_ALICE_BLUE, .T., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 4, RMC_DATAAXISLEFT, 0, 250, 11, 8, RMC_COLOR_BLUE, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, 0, "$", "DATAAXIS4", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 4, "", 1, 10, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, "LABELAXIS4" )
   oChart:AddBarSeries( nChartId, 4, { 240, 230, 220, 180, 170, 160, 145, 130, 125, 115 }, 10, RMC_BARSINGLE, RMC_BAR_FLAT_GRADIENT2, .F., RMC_COLOR_GOLD, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION ChartHalfPie( cFile )

   LOCAL nChartId, oChart := RMChartClass():New()
   LOCAL aColor := { RMC_COLOR_MAROON, RMC_COLOR_MEDIUM_BLUE, RMC_COLOR_CRIMSON, RMC_COLOR_DEFAULT }

   nChartId := oChart:GetChartId()
   oChart:CreateChart( s_hParent, nChartId, 0, 0, CHART_WIDTH, CHART_HEIGHT, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddLegend( nChartId, 1, "North*South*East*West", RMC_LEGEND_BOTTOM, RMC_COLOR_DEFAULT, RMC_LEGENDROUNDRECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddGridlessSeries( nChartId, 1, { 80, 50, 60, 30 }, 4, aColor, 4, RMC_DONUT_3D_GRADIENT, RMC_HALF_TOP, 0, .F., RMC_VLABEL_PERCENT, RMC_HATCHBRUSH_OFF, 0 )
   oChart:SetWatermark( "chartclass", RMC_COLOR_AUTUMN_ORANGE, 25, RMC_TEXTCENTER, 0 )

   RETURN SaveChart( oChart, nChartId, cFile )

STATIC FUNCTION SaveChart( oChart, nChartId, cFile )

   LOCAL nResult

   oChart:Draw( nChartId )
   nResult := oChart:Draw2File( nChartId, cFile, CHART_WIDTH, CHART_HEIGHT, 0 )
   oChart:Reset( nChartId )
   oChart:DeleteChart( nChartId )
   oChart:SetWatermark( "", 0, 0, 0, 0 )

   RETURN nResult
