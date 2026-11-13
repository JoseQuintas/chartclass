/*
MORESAMPLES - more chartclass samples, used by all tests
Graphic11 line/area with tooltips
Graphic12 XY scatter
Graphic13 candlestick + volume bars
Graphic14 bars with trend line
Graphic15 save to PNG and RMC file
Graphic16 chart from RMC file (created on Graphic15)
*/

#include "ze_chartclass.ch"

FUNCTION Graphic11( hWnd, nWidth, nHeight, cFile )

   LOCAL nChartId, oChart := ChartClass():New()
   LOCAL cLabels := "Jan*Feb*Mar*Apr*May*Jun*Jul*Aug*Sep*Oct*Nov*Dec"
   LOCAL aData1  := { 30, 45, 40, 60, 75, 70, 85, 80, 65, 55, 50, 40 }
   LOCAL aData2  := { 20, 25, 35, 30, 45, 55, 50, 60, 70, 60, 45, 35 }

   nChartId := oChart:GetChartId()

   // last but one parameter: tooltip width, mouse over a point shows the value
   oChart:CreateChart( hWnd, nChartId, 0, 0, nWidth, nHeight, RMC_COLOR_AZURE, RMC_CTRLSTYLEFLAT, .F., "", "Tahoma", 100, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "mouse over a point shows the value", .F. )
   oChart:AddCaption( nChartId, 1, "Line and area", RMC_COLOR_BLUE, RMC_COLOR_YELLOW, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, cLabels, 1, 12, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddLegend( nChartId, 1, "Area*Line", RMC_LEGEND_TOP, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddLineSeries( nChartId, 1, aData1, 12, 0, 0, RMC_AREA, RMC_AREA_FLAT_GRADIENT_V, RMC_LSTYLE_SPLINE, .T., RMC_COLOR_CORN_FLOWER_BLUE, RMC_SYMBOL_NONE, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, aData2, 12, 0, 0, RMC_LINE, RMC_LINE_CABLE, RMC_LSTYLE_LINE, .F., RMC_COLOR_CRIMSON, RMC_SYMBOL_BULLET, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:Draw( nChartId )
   IF HB_ISSTRING( cFile )
      oChart:Draw2File( nChartId, cFile, 0, 0, 0 )
   ENDIF
   // no Reset() here, tooltips need the chart data

   RETURN NIL

FUNCTION Graphic12( hWnd, nWidth, nHeight, cFile )

   LOCAL nChartId, oChart := ChartClass():New()
   LOCAL aX1 := { 10, 20, 30, 40, 50, 60, 70, 80, 90 }
   LOCAL aY1 := { 15, 35, 30, 55, 50, 70, 65, 85, 90 }
   LOCAL aX2 := { 5, 15, 35, 45, 55, 65, 75, 85, 95 }
   LOCAL aY2 := { 80, 70, 72, 50, 40, 45, 30, 20, 10 }

   nChartId := oChart:GetChartId()

   oChart:CreateChart( hWnd, nChartId, 0, 0, nWidth, nHeight, RMC_COLOR_STEEL_BLUE, RMC_CTRLSTYLEFLAT, .F., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "XY scatter", RMC_COLOR_ALICE_BLUE, RMC_COLOR_BLACK, 10, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_DARK_BLUE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   // X and Y axis always in pairs
   oChart:AddXAxis( nChartId, 1, RMC_XAXISBOTTOM, 0, 100, 11, 8, RMC_COLOR_BLANCHED_ALMOND, RMC_COLOR_WHITE, RMC_LINESTYLENONE, 0, "", "X Axis", "", RMC_TEXTCENTER )
   oChart:AddYAxis( nChartId, 1, RMC_YAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLANCHED_ALMOND, RMC_COLOR_WHITE, RMC_LINESTYLENONE, 0, "", "Y Axis", "", RMC_TEXTCENTER )
   oChart:AddXYSeries( nChartId, 1, aX1, Len( aX1 ), aY1, Len( aY1 ), RMC_COLOR_WHITE_SMOKE, RMC_XY_LINE_DASH, RMC_LSTYLE_LINE, RMC_SYMBOL_STAR, RMC_XAXISBOTTOM, RMC_YAXISLEFT, RMC_VLABEL_NONE )
   oChart:AddXYSeries( nChartId, 1, aX2, Len( aX2 ), aY2, Len( aY2 ), RMC_COLOR_GOLD, RMC_XY_SYMBOL, RMC_LSTYLE_LINE, RMC_SYMBOL_DIAMOND, RMC_XAXISBOTTOM, RMC_YAXISLEFT, RMC_VLABEL_NONE )
   oChart:Draw( nChartId )
   IF HB_ISSTRING( cFile )
      oChart:Draw2File( nChartId, cFile, 0, 0, 0 )
   ENDIF
   oChart:Reset( nChartId )

   RETURN NIL

FUNCTION Graphic13( hWnd, nWidth, nHeight, cFile )

   LOCAL nChartId, oChart := ChartClass():New()
   LOCAL aOHLC := {}, aVolume := {}, aPPC := {}, cLabels := "", nCont, nOpen, nClose, nPrice := 50

   nChartId := oChart:GetChartId()

   // 20 days of fake prices: open, high, low, close for each day
   FOR nCont = 1 TO 20
      nOpen  := nPrice
      nClose := nOpen + ( ( nCont * 7 ) % 11 ) - 5
      AAdd( aOHLC, nOpen )
      AAdd( aOHLC, Max( nOpen, nClose ) + ( nCont % 3 ) + 1 )
      AAdd( aOHLC, Min( nOpen, nClose ) - ( nCont % 4 ) - 1 )
      AAdd( aOHLC, nClose )
      AAdd( aVolume, 1000 + ( ( nCont * 37 ) % 9 ) * 250 )
      AAdd( aPPC, 1 )
      cLabels += iif( nCont == 1, "", "*" ) + Ltrim( Str( nCont ) )
      nPrice := nClose
   NEXT

   oChart:CreateChart( hWnd, nChartId, 0, 0, nWidth, nHeight, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .F., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   // region 1: prices, upper 70%
   oChart:AddRegion( nChartId, 5, 5, -5, Int( nHeight * 0.7 ), "", .F. )
   oChart:AddCaption( nChartId, 1, "Candlestick and volume", RMC_COLOR_NAVY, RMC_COLOR_WHITE, 10, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_BEIGE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 30, 70, 9, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, cLabels, 1, 20, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   // 4 values per day, aPPC = how many days in each column
   oChart:AddHighLowSeries( nChartId, 1, aOHLC, Len( aOHLC ), aPPC, Len( aPPC ), RMC_CANDLESTICK, 1, RMC_COLOR_RED, RMC_COLOR_LIME_GREEN )
   // region 2: volume, lower 30%
   oChart:AddRegion( nChartId, 5, Int( nHeight * 0.7 ) + 5, -5, -5, "", .F. )
   oChart:AddGrid( nChartId, 2, RMC_COLOR_BEIGE, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 2, RMC_DATAAXISLEFT, 0, 4000, 5, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 2, cLabels, 1, 20, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   // AddVolumeBarSeries() did not align with columns on tests, using bars
   oChart:AddBarSeries( nChartId, 2, aVolume, Len( aVolume ), RMC_BARSINGLE, RMC_COLUMN_FLAT, .F., RMC_COLOR_STEEL_BLUE, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oChart:Draw( nChartId )
   IF HB_ISSTRING( cFile )
      oChart:Draw2File( nChartId, cFile, 0, 0, 0 )
   ENDIF
   oChart:Reset( nChartId )

   RETURN NIL

FUNCTION Graphic14( hWnd, nWidth, nHeight, cFile )

   LOCAL nChartId, oChart := ChartClass():New()
   LOCAL aData := { 42, 38, 51, 47, 55, 60, 52, 66, 63, 71, 68, 77 }
   LOCAL aTrend := TrendLine( aData ), nGrowth

   nChartId := oChart:GetChartId()
   nGrowth  := aTrend[ 2 ] - aTrend[ 1 ]

   oChart:CreateChart( hWnd, nChartId, 0, 0, nWidth, nHeight, RMC_COLOR_ALICE_BLUE, RMC_CTRLSTYLEFLAT, .F., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nChartId, 1, "Sales with trend line, +" + Ltrim( Str( nGrowth, 6, 2 ) ) + " by month", RMC_COLOR_BLUE, RMC_COLOR_YELLOW, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_WHITE, .F., 0, 0, 0, 0, RMC_BICOLOR_LABELAXIS )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "1*2*3*4*5*6*7*8*9*10*11*12", 1, 12, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddLegend( nChartId, 1, "Sales*Trend", RMC_LEGEND_TOP, RMC_COLOR_DEFAULT, RMC_LEGENDNORECT, RMC_COLOR_DEFAULT, 8, .F. )
   oChart:AddBarSeries( nChartId, 1, aData, 12, RMC_BARSINGLE, RMC_BAR_FLAT_GRADIENT2, .F., RMC_COLOR_CORN_FLOWER_BLUE, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oChart:AddLineSeries( nChartId, 1, aTrend, 12, 0, 0, RMC_LINE, RMC_LINE_FLAT_DASH, RMC_LSTYLE_LINE, .F., RMC_COLOR_RED, RMC_SYMBOL_NONE, 1, RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF )
   oChart:Draw( nChartId )
   IF HB_ISSTRING( cFile )
      oChart:Draw2File( nChartId, cFile, 0, 0, 0 )
   ENDIF
   oChart:Reset( nChartId )

   RETURN NIL

FUNCTION Graphic15( hWnd, nWidth, nHeight, cFile )

   LOCAL nChartId, oChart := ChartClass():New()
   LOCAL aData := { 25, 40, 35, 60, 45 }

   nChartId := oChart:GetChartId()

   oChart:CreateChart( hWnd, nChartId, 0, 0, nWidth, nHeight, RMC_COLOR_BISQUE, RMC_CTRLSTYLE3DLIGHT, .F., "", "Tahoma", 0, RMC_COLOR_DEFAULT )
   oChart:AddRegion( nChartId, 5, 5, -5, -5, "saved to chartclass_test.png and chartclass_test.rmc", .F. )
   oChart:AddCaption( nChartId, 1, "Save to file", RMC_COLOR_BISQUE, RMC_COLOR_BLACK, 11, .T. )
   oChart:AddGrid( nChartId, 1, RMC_COLOR_CORN_SILK, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oChart:AddDataAxis( nChartId, 1, RMC_DATAAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nChartId, 1, "North*South*East*West*Center", 1, 5, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLESOLID, "" )
   oChart:AddBarSeries( nChartId, 1, aData, 5, RMC_BARSINGLE, RMC_BAR_3D, .F., RMC_COLOR_DARK_GREEN, .F., 1, RMC_VLABEL_DEFAULT, 1, RMC_HATCHBRUSH_OFF )
   oChart:Draw( nChartId )
   IF HB_ISSTRING( cFile )
      oChart:Draw2File( nChartId, cFile, 0, 0, 0 )
   ENDIF
   // png/jpg/emf by extension, to use on PDF, email, etc.
   oChart:Draw2File( nChartId, "chartclass_test.png", 0, 0, 0 )
   // RMC file can be loaded with CreateChartFromFile(), see Graphic16
   oChart:WriteRMCFile( nChartId, "chartclass_test.rmc" )
   oChart:Reset( nChartId )

   RETURN NIL

FUNCTION Graphic16( hWnd, nWidth, nHeight, cFile )

   LOCAL nChartId, oChart := ChartClass():New()

   nChartId := oChart:GetChartId()

   IF ! File( "chartclass_test.rmc" )
      // create file before, without show
      Graphic15( hWnd, nWidth, nHeight )
   ENDIF
   // all from file, size too
   oChart:CreateChartFromFile( hWnd, nChartId, 0, 0, .F., "chartclass_test.rmc" )
   oChart:SetCaptionText( nChartId, 1, "Loaded from chartclass_test.rmc" )
   oChart:Draw( nChartId )
   IF HB_ISSTRING( cFile )
      oChart:Draw2File( nChartId, cFile, 0, 0, 0 )
   ENDIF
   oChart:Reset( nChartId )

   RETURN NIL

STATIC FUNCTION TrendLine( aData )

   // linear least square fit, the same method of RMC_CalcTrend()
   LOCAL nCont, nLen := Len( aData ), nSumX := 0, nSumY := 0, nSumXY := 0, nSumX2 := 0
   LOCAL nSlope, nBase, aTrend := {}

   FOR nCont = 1 TO nLen
      nSumX  += nCont
      nSumY  += aData[ nCont ]
      nSumXY += nCont * aData[ nCont ]
      nSumX2 += nCont * nCont
   NEXT
   nSlope := ( nLen * nSumXY - nSumX * nSumY ) / ( nLen * nSumX2 - nSumX * nSumX )
   nBase  := ( nSumY - nSlope * nSumX ) / nLen
   FOR nCont = 1 TO nLen
      AAdd( aTrend, nBase + nSlope * nCont )
   NEXT

   RETURN aTrend
