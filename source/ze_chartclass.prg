/*
ZE_CHARTCLASS - charts for Harbour drawn with GDI+, 32 and 64 bits
2026.10 José Quintas

Inspired by RMChart, with a compatible RMC_* API.
The engine is on ze_chartengine.c, functions RMC_*() can be called direct too.
RMChartClass() is the same class, to change rmchartclass to chartclass without changing source code.
*/

#include "hbclass.ch"

FUNCTION RMChartClass()

   RETURN ChartClass()

CREATE CLASS ChartClass

   VAR    hDLL                             INIT NIL
   VAR    aIdChartList                     INIT {}
   CLASSVAR ChartID                        INIT 1

   METHOD Init()                           INLINE Self
   METHOD Destroy()                        INLINE NIL
   METHOD GetChartID()                     INLINE ::ChartID += 1, AAdd( ::aIdChartList, ::ChartID ), ::ChartID
   METHOD FreeChartList()
   METHOD AddHightLowSeries( ... )         INLINE ::AddHighLowSeries( ... ) // old name
   METHOD AddXSeries( ... )                INLINE ::AddXYSeries( ... ) // old name
   METHOD AddYSeries( ... )                INLINE ::AddXYSeries( ... ) // old name
   METHOD CreateChartOnDc( ... )           INLINE RMC_CREATECHARTONDC( ... )
   METHOD AddBarSeries( ... )              INLINE RMC_ADDBARSERIES( ... )
   METHOD AddRegion( ... )                 INLINE RMC_ADDREGION( ... )
   METHOD AddCaption( ... )                INLINE RMC_ADDCAPTION( ... )
   METHOD AddDataAxis( ... )               INLINE RMC_ADDDATAAXIS( ... )
   METHOD AddGrid( ... )                   INLINE RMC_ADDGRID( ... )
   METHOD AddGridLessSeries( ... )         INLINE RMC_ADDGRIDLESSSERIES( ... )
   METHOD AddHighLowSeries( ... )          INLINE RMC_ADDHIGHLOWSERIES( ... )
   METHOD AddLabelAxis( ... )              INLINE RMC_ADDLABELAXIS( ... )
   METHOD AddLegend( ... )                 INLINE RMC_ADDLEGEND( ... )
   METHOD AddLineSeries( ... )             INLINE RMC_ADDLINESERIES( ... )
   METHOD AddToolTips( ... )               INLINE RMC_ADDTOOLTIPS( ... )
   METHOD AddVolumeBarSeries( ... )        INLINE RMC_ADDVOLUMEBARSERIES( ... )
   METHOD AddXAxis( ... )                  INLINE RMC_ADDXAXIS( ... )
   METHOD AddXYSeries( ... )               INLINE RMC_ADDXYSERIES( ... )
   METHOD AddYAxis( ... )                  INLINE RMC_ADDYAXIS( ... )
   METHOD CalcAverage( ... )               INLINE RMC_CALCAVERAGE( ... )
   METHOD CalcTrend( ... )                 INLINE RMC_CALCTREND( ... )
   METHOD CoBox( ... )                     INLINE RMC_COBOX( ... )
   METHOD CoCircle( ... )                  INLINE RMC_COCIRCLE( ... )
   METHOD CoDash( ... )                    INLINE RMC_CODASH( ... )
   METHOD CoDelete( ... )                  INLINE RMC_CODELETE( ... )
   METHOD CoImage( ... )                   INLINE RMC_COIMAGE( ... )
   METHOD CoLine( ... )                    INLINE RMC_COLINE( ... )
   METHOD CoPolygon( ... )                 INLINE RMC_COPOLYGON( ... )
   METHOD CoSymbol( ... )                  INLINE RMC_COSYMBOL( ... )
   METHOD CoText( ... )                    INLINE RMC_COTEXT( ... )
   METHOD CoVisible( ... )                 INLINE RMC_COVISIBLE( ... )
   METHOD CreateChart( ... )               INLINE RMC_CREATECHART( ... )
   METHOD CreateChartFromFile( ... )       INLINE RMC_CREATECHARTFROMFILE( ... )
   METHOD DeleteChart( ... )               INLINE RMC_DELETECHART( ... )
   METHOD Draw( ... )                      INLINE RMC_DRAW( ... )
   METHOD Draw2Clipboard( ... )            INLINE RMC_DRAW2CLIPBOARD( ... )
   METHOD Draw2Printer( ... )              INLINE RMC_DRAW2PRINTER( ... )
   METHOD Draw2File( ... )                 INLINE RMC_DRAW2FILE( ... )
   METHOD GetChartSizeFromFile( ... )      INLINE RMC_GETCHARTSIZEFROMFILE( ... )
   METHOD GetCtrlHeight( ... )             INLINE RMC_GETCTRLHEIGHT( ... )
   METHOD GetCtrlWidth( ... )              INLINE RMC_GETCTRLWIDTH( ... )
   METHOD GetData( ... )                   INLINE RMC_GETDATA( ... )
   METHOD GetDataCount( ... )              INLINE RMC_GETDATACOUNT( ... )
   METHOD GetDataLocation( ... )           INLINE RMC_GETDATALOCATION( ... )
   METHOD GetDataLocationXY( ... )         INLINE RMC_GETDATALOCATIONXY( ... )
   METHOD GetGridLocation( ... )           INLINE RMC_GETGRIDLOCATION( ... )
   METHOD GetHighPart( ... )               INLINE RMC_GETHIGHPART( ... )
   METHOD GetImageSizeFromFile( ... )      INLINE RMC_GETIMAGESIZEFROMFILE( ... )
   METHOD GetInfo( ... )                   INLINE RMC_GETINFO( ... )
   METHOD GetInfoXY( ... )                 INLINE RMC_GETINFOXY( ... )
   METHOD GeTLowPart( ... )                INLINE RMC_GETLOWPART( ... )
   METHOD GetSeriesDataRange( ... )        INLINE RMC_GETSERIESDATARANGE( ... )
   METHOD GetVersion( ... )                INLINE RMC_GETVERSION( ... )
   METHOD Magnifier( ... )                 INLINE RMC_MAGNIFIER( ... )
   METHOD Paint( ... )                     INLINE RMC_PAINT( ... )
   METHOD Refresh( ... )                   INLINE RMC_REFRESH( ... )
   METHOD Reset( ... )                     INLINE RMC_RESET( ... )
   METHOD Rnd( ... )                       INLINE RMC_RND( ... )
   METHOD SaveBMP( ... )                   INLINE RMC_SAVEBMP( ... )
   METHOD SetCaptionText( ... )            INLINE RMC_SETCAPTIONTEXT( ... )
   METHOD SetCaptionBGColor( ... )         INLINE RMC_SETCAPTIONBGCOLOR( ... )
   METHOD SetCaptionTextColor( ... )       INLINE RMC_SETCAPTIONTEXTCOLOR( ... )
   METHOD SetCaptionFontBold( ... )        INLINE RMC_SETCAPTIONFONTBOLD( ... )
   METHOD SetCaptionFontSize( ... )        INLINE RMC_SETCAPTIONFONTSIZE( ... )
   METHOD SetCtrlBGColor( ... )            INLINE RMC_SETCTRLBGCOLOR( ... )
   METHOD SetCtrlBGImage( ... )            INLINE RMC_SETCTRLBGIMAGE( ... )
   METHOD SetCtrlFont( ... )               INLINE RMC_SETCTRLFONT( ... )
   METHOD SetCtrlSize( ... )               INLINE RMC_SETCTRLSIZE( ... )
   METHOD SetCtrlStyle( ... )              INLINE RMC_SETCTRLSTYLE( ... )
   METHOD SetCustomTooltipText( ... )      INLINE RMC_SETCUSTOMTOOLTIPTEXT( ... )
   METHOD SetDataXAlignment( ... )         INLINE RMC_SETDAXALIGNMENT( ... )
   METHOD SetDaXDecimalDigits( ... )       INLINE RMC_SETDAXDECIMALDIGITS( ... )
   METHOD SetDaXFontSize( ... )            INLINE RMC_SETDAXFONTSIZE( ... )
   METHOD SetDaXLineColor( ... )           INLINE RMC_SETDAXLINECOLOR( ... )
   METHOD SetDaXLineStyle( ... )           INLINE RMC_SETDAXLINESTYLE( ... )
   METHOD SetDaXMaxValue( ... )            INLINE RMC_SETDAXMAXVALUE( ... )
   METHOD SetDaXMinValue( ... )            INLINE RMC_SETDAXMINVALUE( ... )
   METHOD SetDaXText( ... )                INLINE RMC_SETDAXTEXT( ... )
   METHOD SetDaXTextColor( ... )           INLINE RMC_SETDAXTEXTCOLOR( ... )
   METHOD SetDaXTickCount( ... )           INLINE RMC_SETDAXTICKCOUNT( ... )
   METHOD SetDaXUnit( ... )                INLINE RMC_SETDAXUNIT( ... )
   METHOD SetDaXLabels( ... )              INLINE RMC_SETDAXLABELS( ... )
   METHOD SetDaXLabelAlignment( ... )      INLINE RMC_SETDAXLABELALIGNMENT( ... )
   METHOD SetGridBGColor( ... )            INLINE RMC_SETGRIDBGCOLOR( ... )
   METHOD SetGridBIColor( ... )            INLINE RMC_SETGRIDBICOLOR( ... )
   METHOD SetGridGradient( ... )           INLINE RMC_SETGRIDGRADIENT( ... )
   METHOD SetGridMargin( ... )             INLINE RMC_SETGRIDMARGIN( ... )
   METHOD SetHelpIngGrid( ... )            INLINE RMC_SETHELPINGGRID( ... )
   METHOD SetLAXAlignment( ... )           INLINE RMC_SETLAXALIGNMENT( ... )
   METHOD SetLAXCount( ... )               INLINE RMC_SETLAXCOUNT( ... )
   METHOD SetLAXFontSize( ... )            INLINE RMC_SETLAXFONTSIZE( ... )
   METHOD SetLAXLabelAlignment( ... )      INLINE RMC_SETLAXLABELALIGNMENT( ... )
   METHOD SetLAXLabels( ... )              INLINE RMC_SETLAXLABELS( ... )
   METHOD SetLAXLabelsFile( ... )          INLINE RMC_SETLAXLABELSFILE( ... )
   METHOD SetLAXLabelsRange( ... )         INLINE RMC_SETLAXLABELSRANGE( ... )
   METHOD SetLAXLineColor( ... )           INLINE RMC_SETLAXLINECOLOR( ... )
   METHOD SetLAXLineStyle( ... )           INLINE RMC_SETLAXLINESTYLE( ... )
   METHOD SetLAXTextColor( ... )           INLINE RMC_SETLAXTEXTCOLOR( ... )
   METHOD SetLAXText( ... )                INLINE RMC_SETLAXTEXT( ... )
   METHOD SetLAXTickCount( ... )           INLINE RMC_SETLAXTICKCOUNT( ... )
   METHOD SetLegendAlignment( ... )        INLINE RMC_SETLEGENDALIGNMENT( ... )
   METHOD SetLegendBGColor( ... )          INLINE RMC_SETLEGENDBGCOLOR( ... )
   METHOD SetLegendFontBold( ... )         INLINE RMC_SETLEGENDFONTBOLD( ... )
   METHOD SetLegendFontSize( ... )         INLINE RMC_SETLEGENDFONTSIZE( ... )
   METHOD SetLegendHide( ... )             INLINE RMC_SETLEGENDHIDE( ... )
   METHOD SetLegendStyle( ... )            INLINE RMC_SETLEGENDSTYLE( ... )
   METHOD SetLegendText( ... )             INLINE RMC_SETLEGENDTEXT( ... )
   METHOD SetLegendTextColor( ... )        INLINE RMC_SETLEGENDTEXTCOLOR( ... )
   METHOD SetMouseClick( ... )             INLINE RMC_SETMOUSECLICK( ... )
   METHOD SetRegionFooter( ... )           INLINE RMC_SETREGIONFOOTER( ... )
   METHOD SetRegionMargin( ... )           INLINE RMC_SETREGIONMARGIN( ... )
   METHOD SetRegionBorder( ... )           INLINE RMC_SETREGIONBORDER( ... )
   METHOD SetRMCFile( ... )                INLINE RMC_SETRMCFILE( ... )
   METHOD SetSeriesColor( ... )            INLINE RMC_SETSERIESCOLOR( ... )
   METHOD SetSeriesExplodeMode( ... )      INLINE RMC_SETSERIESEXPLODEMODE( ... )
   METHOD SetSeriesStartAngle( ... )       INLINE RMC_SETSERIESSTARTANGLE( ... )
   METHOD SetSeriesData( ... )             INLINE RMC_SETSERIESDATA( ... )
   METHOD SetSeriesDataFile( ... )         INLINE RMC_SETSERIESDATAFILE( ... )
   METHOD SetSeriesDataRange( ... )        INLINE RMC_SETSERIESDATARANGE( ... )
   METHOD SetSeriesSingleData( ... )       INLINE RMC_SETSERIESSINGLEDATA( ... )
   METHOD SetSeriesDataAxis( ... )         INLINE RMC_SETSERIESDATAAXIS( ... )
   METHOD SetSeriesHatchMode( ... )        INLINE RMC_SETSERIESHATCHMODE( ... )
   METHOD SetSeriesHide( ... )             INLINE RMC_SETSERIESHIDE( ... )
   METHOD SetSeriesHightLowColor( ... )    INLINE RMC_SETSERIESHIGHLOWCOLOR( ... )
   METHOD SetSeriesLineStyle( ... )        INLINE RMC_SETSERIESLINESTYLE( ... )
   METHOD SetSeriesLucent( ... )           INLINE RMC_SETSERIESLUCENT( ... )
   METHOD SetSeriesPPColumn( ... )         INLINE RMC_SETSERIESPPCOLUMN( ... )
   METHOD SetSeriesPPColumnArray( ... )    INLINE RMC_SETSERIESPPCOLUMNARRAY( ... )
   METHOD SetSeriesVertical( ... )         INLINE RMC_SETSERIESVERTICAL( ... )
   METHOD SetSeriesStyle( ... )            INLINE RMC_SETSERIESSTYLE( ... )
   METHOD SetSeriesSymbol( ... )           INLINE RMC_SETSERIESSYMBOL( ... )
   METHOD SetSeriesValueLabel( ... )       INLINE RMC_SETSERIESVALUELABEL( ... )
   METHOD SetSeriesXAxis( ... )            INLINE RMC_SETSERIESXAXIS( ... )
   METHOD SetSeriesYAxis( ... )            INLINE RMC_SETSERIESYAXIS( ... )
   METHOD SetSingleBarColors( ... )        INLINE RMC_SETSINGLEBARCOLORS( ... )
   METHOD SetTooltipWidth( ... )           INLINE RMC_SETTOOLTIPWIDTH( ... )
   METHOD SetWaterMark( ... )              INLINE RMC_SETWATERMARK( ... )
   METHOD SetXAXAlignment( ... )           INLINE RMC_SETXAXALIGNMENT( ... )
   METHOD SetYAXAlignment( ... )           INLINE RMC_SETYAXALIGNMENT( ... )
   METHOD SetXAXDecimalDigits( ... )       INLINE RMC_SETXAXDECIMALDIGITS( ... )
   METHOD SetYAXDecimalDigits( ... )       INLINE RMC_SETYAXDECIMALDIGITS( ... )
   METHOD SetXAXFontSize( ... )            INLINE RMC_SETXAXFONTSIZE( ... )
   METHOD SetYAXFontSize( ... )            INLINE RMC_SETYAXFONTSIZE( ... )
   METHOD SetXAXLabels( ... )              INLINE RMC_SETXAXLABELS( ... )
   METHOD SetYAXLabels( ... )              INLINE RMC_SETYAXLABELS( ... )
   METHOD SetXAXLabelAlignment( ... )      INLINE RMC_SETXAXLABELALIGNMENT( ... )
   METHOD SetYAXLabelAlignment( ... )      INLINE RMC_SETYAXLABELALIGNMENT( ... )
   METHOD SetXAXLineColor( ... )           INLINE RMC_SETXAXLINECOLOR( ... )
   METHOD SetYAXLineCOlor( ... )           INLINE RMC_SETYAXLINECOLOR( ... )
   METHOD SetXAXLineStyle( ... )           INLINE RMC_SETXAXLINESTYLE( ... )
   METHOD SetYAXLineStyle( ... )           INLINE RMC_SETYAXLINESTYLE( ... )
   METHOD SetXAXMaxValue( ... )            INLINE RMC_SETXAXMAXVALUE( ... )
   METHOD SetYAXMaxValue( ... )            INLINE RMC_SETYAXMAXVALUE( ... )
   METHOD SetXAXMinValue( ... )            INLINE RMC_SETXAXMINVALUE( ... )
   METHOD SetYAXMinValue( ... )            INLINE RMC_SETYAXMINVALUE( ... )
   METHOD SetXAXText( ... )                INLINE RMC_SETXAXTEXT( ... )
   METHOD SetYAXText( ... )                INLINE RMC_SETYAXTEXT( ... )
   METHOD SetXAXTextColor( ... )           INLINE RMC_SETXAXTEXTCOLOR( ... )
   METHOD SetYAXTextColor( ... )           INLINE RMC_SETYAXTEXTCOLOR( ... )
   METHOD SetXAXTickCount( ... )           INLINE RMC_SETXAXTICKCOUNT( ... )
   METHOD SetYAXTickCount( ... )           INLINE RMC_SETYAXTICKCOUNT( ... )
   METHOD SetXAXUnit( ... )                INLINE RMC_SETXAXUNIT( ... )
   METHOD SetYAXUnit( ... )                INLINE RMC_SETYAXUNIT( ... )
   METHOD ShowTooltips( ... )              INLINE RMC_SHOWTOOLTIPS( ... )
   METHOD Split( ... )                     INLINE RMC_SPLIT( ... )
   METHOD Split2Double( ... )              INLINE RMC_SPLIT2DOUBLE( ... )
   METHOD Split2Long( ... )                INLINE RMC_SPLIT2LONG( ... )
   METHOD WriteRMCFile( ... )              INLINE RMC_WRITERMCFILE( ... )
   METHOD Zoom( ... )                      INLINE RMC_ZOOM( ... )
   METHOD SetNumberFormat( ... )           INLINE CHC_SETNUMBERFORMAT( ... ) // cDecimal, cThousand, cSuffix
   METHOD ToDecimal( xValue )              INLINE xValue + 1.01 - 1.01
   METHOD ToDouble( xValue )               INLINE xValue // arrays are accepted direct
   METHOD ToLong( xValue )                 INLINE xValue // arrays are accepted direct

   ENDCLASS

METHOD FreeChartList() CLASS ChartClass

   LOCAL nChart

   FOR EACH nChart IN ::aIdChartList
      ::Reset( nChart )
   NEXT

   RETURN NIL

/*
RMC_Split*() - text separated by "*" to array, only for compatibility
the engine receives Harbour arrays direct
*/

FUNCTION RMC_SPLIT( cText, aArray )

   RETURN ChartSplit( cText, aArray, { | x | x } )

FUNCTION RMC_SPLIT2DOUBLE( cText, aArray )

   RETURN ChartSplit( cText, aArray, { | x | Val( x ) } )

FUNCTION RMC_SPLIT2LONG( cText, aArray )

   RETURN ChartSplit( cText, aArray, { | x | Int( Val( x ) ) } )

STATIC FUNCTION ChartSplit( cText, aArray, bConvert )

   LOCAL aList := hb_ATokens( iif( ValType( cText ) == "C", cText, "" ), "*" ), xItem

   IF ValType( aArray ) == "A"
      ASize( aArray, 0 )
      FOR EACH xItem IN aList
         AAdd( aArray, Eval( bConvert, xItem ) )
      NEXT
   ENDIF

   RETURN Len( aList )
