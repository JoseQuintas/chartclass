/*
ZE_CHARTRMCFILE - read RMChart *.rmc files (RMC content string)
2026.11 José Quintas

RMC_CreateChartFromFile( hParent, nCtrlId, nX, nY, lExportOnly, cRMCFile ) --> nResult
RMC_GetChartSizeFromFile( cRMCFile, @nWidth, @nHeight ) --> nResult
RMC_File2Source( cRMCFile, [bText], [bData] ) --> cSource with the same RMC_*() calls

cRMCFile is a file name or the content string itself.
Content: fields separated by "|", each field = 5 digit code + value.
   00ccc         chart
   01ccc         custom objects (not drawn yet)
   R0ccc         region R
   RSccc         series S of region R
The chart is created calling the same RMC_*() functions, then RMC_Draw() as usual.
Data can be in the file or in a data file (*.csv), read here.
Not used yet: custom objects, watermark, tooltips, start angle, hidden series.
*/

#include "ze_chartclass.ch"

STATIC s_hSource := Nil

FUNCTION RMC_CreateChartFromFile( hParent, nCtrlId, nX, nY, lExportOnly, cRMCFile )

   LOCAL hRmc, nRegion, nSeries, nResult, cPath := ""

   IF ! RmcLoad( cRMCFile, @hRmc, @cPath )
      RETURN RMC_ERROR_RMCFILE
   ENDIF
   hb_Default( @nX, 0 )
   hb_Default( @nY, 0 )
   IF ValType( lExportOnly ) == "N"
      lExportOnly := ( lExportOnly != 0 )
   ENDIF
   IF ! HB_ISSTRING( lExportOnly ) // string = name of variable, RMC_File2Source()
      hb_Default( @lExportOnly, .F. )
   ENDIF

   nResult := RmcDo( "RMC_CreateChart", hParent, nCtrlId, nX, nY, RmcN( hRmc, 3 ), RmcN( hRmc, 4 ), ;
      RmcN( hRmc, 8 ), RmcN( hRmc, 7 ), lExportOnly, RmcFile( RmcC( hRmc, 10 ), cPath ), RmcC( hRmc, 11 ), ;
      RmcN( hRmc, 12 ), RmcN( hRmc, 13 ) )
   IF nResult < 0
      RETURN nResult
   ENDIF
   FOR nRegion = 1 TO Min( RmcN( hRmc, 5 ), 9 )
      RmcRegion( hRmc, nCtrlId, nRegion, cPath )
      FOR nSeries = 1 TO Min( RmcN( hRmc, nRegion * 10000 + 48 ), 9 )
         RmcSeries( hRmc, nCtrlId, nRegion, nSeries, nRegion * 10000 + nSeries * 1000, cPath )
      NEXT
   NEXT

   RETURN nResult

FUNCTION RMC_GetChartSizeFromFile( cRMCFile, nWidth, nHeight )

   LOCAL hRmc

   IF ! RmcLoad( cRMCFile, @hRmc )
      RETURN RMC_ERROR_RMCFILE
   ENDIF
   nWidth  := RmcN( hRmc, 3 )
   nHeight := RmcN( hRmc, 4 )

   RETURN 0

STATIC FUNCTION RmcRegion( hRmc, nCtrlId, nRegion, cPath )

   LOCAL n := nRegion * 10000

   HB_SYMBOL_UNUSED( cPath )

   RmcDo( "RMC_AddRegion", nCtrlId, RmcN( hRmc, n + 3 ), RmcN( hRmc, n + 4 ), RmcN( hRmc, n + 5 ), RmcN( hRmc, n + 6 ), ;
      RmcC( hRmc, n + 180 ), RmcN( hRmc, n + 2 ) != 0 )
   IF hb_HHasKey( hRmc, n + 181 )
      RmcDo( "RMC_AddCaption", nCtrlId, nRegion, RmcC( hRmc, n + 181 ), RmcN( hRmc, n + 51 ), RmcN( hRmc, n + 52 ), ;
         RmcN( hRmc, n + 9 ), RmcN( hRmc, n + 10 ) != 0 )
   ENDIF
   IF RmcN( hRmc, n + 11 ) != 0
      RmcDo( "RMC_AddGrid", nCtrlId, nRegion, RmcN( hRmc, n + 53 ), RmcN( hRmc, n + 13 ) != 0, ;
         RmcN( hRmc, n + 14 ), RmcN( hRmc, n + 15 ), RmcN( hRmc, n + 16 ), RmcN( hRmc, n + 17 ), RmcN( hRmc, n + 12 ) )
   ENDIF
   IF RmcN( hRmc, n + 11 ) == 2
      // XY: first and second X/Y axis
      RmcDo( "RMC_AddXAxis", nCtrlId, nRegion, RmcN( hRmc, n + 76 ), RmcN( hRmc, n + 68 ), RmcN( hRmc, n + 69 ), ;
         RmcN( hRmc, n + 70 ), RmcN( hRmc, n + 71 ), RmcN( hRmc, n + 77 ), RmcN( hRmc, n + 78 ), RmcN( hRmc, n + 79 ), ;
         RmcN( hRmc, n + 75 ), RmcC( hRmc, n + 188 ), RmcC( hRmc, n + 189 ), RmcC( hRmc, n + 197 ), RmcN( hRmc, n + 80 ) )
      RmcDo( "RMC_AddYAxis", nCtrlId, nRegion, RmcN( hRmc, n + 89 ), RmcN( hRmc, n + 81 ), RmcN( hRmc, n + 82 ), ;
         RmcN( hRmc, n + 83 ), RmcN( hRmc, n + 84 ), RmcN( hRmc, n + 90 ), RmcN( hRmc, n + 91 ), RmcN( hRmc, n + 92 ), ;
         RmcN( hRmc, n + 88 ), RmcC( hRmc, n + 190 ), RmcC( hRmc, n + 191 ), RmcC( hRmc, n + 198 ), RmcN( hRmc, n + 93 ) )
      IF RmcN( hRmc, n + 100 ) != 0
         RmcDo( "RMC_AddXAxis", nCtrlId, nRegion, RmcN( hRmc, n + 100 ), RmcN( hRmc, n + 95 ), RmcN( hRmc, n + 96 ), ;
            RmcN( hRmc, n + 97 ), RmcN( hRmc, n + 98 ), RmcN( hRmc, n + 101 ), RmcN( hRmc, n + 102 ), RmcN( hRmc, n + 103 ), ;
            RmcN( hRmc, n + 99 ), RmcC( hRmc, n + 192 ), RmcC( hRmc, n + 193 ), "", 0 )
      ENDIF
      IF RmcN( hRmc, n + 109 ) != 0
         RmcDo( "RMC_AddYAxis", nCtrlId, nRegion, RmcN( hRmc, n + 109 ), RmcN( hRmc, n + 104 ), RmcN( hRmc, n + 105 ), ;
            RmcN( hRmc, n + 106 ), RmcN( hRmc, n + 107 ), RmcN( hRmc, n + 110 ), RmcN( hRmc, n + 111 ), RmcN( hRmc, n + 112 ), ;
            RmcN( hRmc, n + 108 ), RmcC( hRmc, n + 194 ), RmcC( hRmc, n + 195 ), "", 0 )
      ENDIF
   ELSEIF RmcN( hRmc, n + 11 ) == 1
      IF hb_HHasKey( hRmc, n + 18 )
         RmcDo( "RMC_AddDataAxis", nCtrlId, nRegion, RmcN( hRmc, n + 54 ), RmcN( hRmc, n + 20 ), RmcN( hRmc, n + 21 ), ;
            RmcN( hRmc, n + 22 ), RmcN( hRmc, n + 23 ), RmcN( hRmc, n + 56 ), RmcN( hRmc, n + 57 ), RmcN( hRmc, n + 58 ), ;
            RmcN( hRmc, n + 27 ), RmcC( hRmc, n + 183 ), RmcC( hRmc, n + 184 ), RmcC( hRmc, n + 201 ), RmcN( hRmc, n + 59 ) )
         IF RmcN( hRmc, n + 28 ) > 0
            // second data axis, only these values can be different
            RmcDo( "RMC_AddDataAxis", nCtrlId, nRegion, iif( RmcN( hRmc, n + 94 ) == 0, RMC_DATAAXISRIGHT, RmcN( hRmc, n + 94 ) ), ;
               RmcN( hRmc, n + 30 ), RmcN( hRmc, n + 31 ), RmcN( hRmc, n + 22 ), RmcN( hRmc, n + 23 ), ;
               RmcN( hRmc, n + 56 ), RmcN( hRmc, n + 57 ), RmcN( hRmc, n + 58 ), ;
               RmcN( hRmc, n + 32 ), RmcC( hRmc, n + 185 ), RmcC( hRmc, n + 186 ), "", 0 )
         ENDIF
      ENDIF
      IF hb_HHasKey( hRmc, n + 33 )
         RmcDo( "RMC_AddLabelAxis", nCtrlId, nRegion, RmcC( hRmc, n + 187 ), 1, RmcN( hRmc, n + 35 ), RmcN( hRmc, n + 55 ), ;
            RmcN( hRmc, n + 37 ), RmcN( hRmc, n + 60 ), RmcN( hRmc, n + 50 ), RmcN( hRmc, n + 61 ), RmcN( hRmc, n + 62 ), ;
            RmcC( hRmc, n + 196 ) )
      ENDIF
   ENDIF
   IF hb_HHasKey( hRmc, n + 182 )
      RmcDo( "RMC_AddLegend", nCtrlId, nRegion, RmcC( hRmc, n + 182 ), RmcN( hRmc, n + 63 ), RmcN( hRmc, n + 64 ), ;
         RmcN( hRmc, n + 65 ), RmcN( hRmc, n + 66 ), RmcN( hRmc, n + 46 ), RmcN( hRmc, n + 47 ) != 0 )
   ENDIF

   RETURN Nil

STATIC FUNCTION RmcSeries( hRmc, nCtrlId, nRegion, nSeries, n, cPath )

   LOCAL nType := RmcN( hRmc, n + 2 ), aData, aPPC, aColor, aY, nCont, nAxis, nR, nXAxis, nYAxis

   aData  := RmcData( hRmc, n, 53, 55, cPath )
   aPPC   := RmcArray( RmcC( hRmc, n + 52 ) )
   aColor := RmcArray( RmcC( hRmc, n + 51 ) )
   nAxis  := RmcN( hRmc, n + 11 ) + 1 // saved as axis - 1
   DO CASE
   CASE nType >= RMC_BARSINGLE .AND. nType <= RMC_FLOATINGBARGROUP
      RmcDo( "RMC_AddBarSeries", nCtrlId, nRegion, aData, Len( aData ), nType, RmcN( hRmc, n + 4 ), RmcN( hRmc, n + 8 ) != 0, ;
         iif( RmcN( hRmc, n + 28 ) == 1, RMC_COLOR_TRANSPARENT, RmcN( hRmc, n + 19 ) ), ; // 28 = one color by bar
         RmcN( hRmc, n + 10 ) != 0, nAxis, RmcN( hRmc, n + 12 ), Max( RmcN( hRmc, n + 13 ), 1 ), ;
         RmcN( hRmc, n + 20 ) )
      // colors by bar, 0 = series color
      FOR nCont = 1 TO Len( aColor )
         IF aColor[ nCont ] != 0
            RmcDo( "RMC_SetSeriesColor", nCtrlId, nRegion, nSeries, aColor[ nCont ], nCont )
         ENDIF
      NEXT
   CASE nType >= RMC_LINE .AND. nType <= RMC_AREA_STACKED100
      RmcDo( "RMC_AddLineSeries", nCtrlId, nRegion, aData, Len( aData ), aPPC, Len( aPPC ), nType, RmcN( hRmc, n + 4 ), ;
         RmcN( hRmc, n + 6 ), RmcN( hRmc, n + 8 ) != 0, RmcN( hRmc, n + 19 ), RmcN( hRmc, n + 14 ), nAxis, ;
         RmcN( hRmc, n + 12 ), RmcN( hRmc, n + 20 ) )
   CASE nType == RMC_VOLUMEBAR
      RmcDo( "RMC_AddVolumeBarSeries", nCtrlId, nRegion, aData, Len( aData ), aPPC, Len( aPPC ), RmcN( hRmc, n + 19 ), nAxis )
   CASE nType == RMC_HIGHLOW
      ASize( aColor, 2 )
      RmcDo( "RMC_AddHighLowSeries", nCtrlId, nRegion, aData, Len( aData ), aPPC, Len( aPPC ), RmcN( hRmc, n + 4 ), nAxis, ;
         hb_DefaultValue( aColor[ 1 ], 0 ), hb_DefaultValue( aColor[ 2 ], 0 ) )
   CASE nType == RMC_GRIDLESS
      RmcDo( "RMC_AddGridlessSeries", nCtrlId, nRegion, aData, Len( aData ), aColor, Len( aColor ), RmcN( hRmc, n + 4 ), ;
         RmcN( hRmc, n + 16 ), RmcN( hRmc, n + 18 ), RmcN( hRmc, n + 8 ) != 0, RmcN( hRmc, n + 12 ), ;
         RmcN( hRmc, n + 20 ), 0 )
   CASE nType == RMC_XYCHART
      aY := RmcData( hRmc, n, 54, 59, cPath )
      // pair of X/Y axis, the engine uses the alignment of the axis
      nR := Int( n / 10000 ) * 10000
      nXAxis := iif( RmcN( hRmc, n + 27 ) == 2, RmcN( hRmc, nR + 100 ), RmcN( hRmc, nR + 76 ) )
      nYAxis := iif( RmcN( hRmc, n + 27 ) == 2, RmcN( hRmc, nR + 109 ), RmcN( hRmc, nR + 89 ) )
      RmcDo( "RMC_AddXYSeries", nCtrlId, nRegion, aData, Len( aData ), aY, Len( aY ), RmcN( hRmc, n + 19 ), ;
         RmcN( hRmc, n + 4 ), RmcN( hRmc, n + 6 ), RmcN( hRmc, n + 14 ), nXAxis, nYAxis, RmcN( hRmc, n + 12 ) )
   ENDCASE

   RETURN Nil

// data in the content (nData) or in a data file (nFile = name, +1 fields, +2 lines, +3 delimiter)
STATIC FUNCTION RmcData( hRmc, n, nData, nFile, cPath )

   IF hb_HHasKey( hRmc, n + nData )
      RETURN RmcArray( RmcC( hRmc, n + nData ) )
   ENDIF
   IF hb_HHasKey( hRmc, n + nFile )
      RETURN RmcDataFile( RmcFile( RmcC( hRmc, n + nFile ), cPath ), RmcC( hRmc, n + nFile + 2 ), ;
         RmcC( hRmc, n + nFile + 1 ), RmcC( hRmc, n + nFile + 3 ) )
   ENDIF

   RETURN {}

// as RMC_SetSeriesDataFile(): cLines "" all, "-1" all reverse, "20" first 20, "-10" last 10, "10,50" or "50,10"
// cFields "" all, "2,5" these, "2-5" range
STATIC FUNCTION RmcDataFile( cFile, cLines, cFields, cDelim )

   LOCAL aLines := {}, cLine, aList := {}, nFirst, nLast, nStep, nLine, aField, aFieldList, nField, nPos

   FOR EACH cLine IN hb_ATokens( StrTran( hb_MemoRead( cFile ), Chr( 13 ), "" ), Chr( 10 ) )
      IF ! Empty( cLine )
         AAdd( aLines, cLine )
      ENDIF
   NEXT
   IF Empty( aLines )
      RETURN {}
   ENDIF
   IF Empty( cDelim )
      cDelim := ","
   ENDIF
   cLines := AllTrim( cLines )
   DO CASE
   CASE Empty( cLines ) .OR. cLines == "0"
      nFirst := 1
      nLast  := Len( aLines )
   CASE cLines == "-1"
      nFirst := Len( aLines )
      nLast  := 1
   CASE "," $ cLines
      nFirst := RmcLine( Val( cLines ), Len( aLines ) )
      nLast  := RmcLine( Val( Substr( cLines, At( ",", cLines ) + 1 ) ), Len( aLines ) )
   CASE Val( cLines ) < 0
      nFirst := Len( aLines )
      nLast  := Len( aLines ) + Val( cLines ) + 1
   OTHERWISE
      nFirst := 1
      nLast  := Val( cLines )
   ENDCASE
   nFirst := Max( Min( nFirst, Len( aLines ) ), 1 )
   nLast  := Max( Min( nLast, Len( aLines ) ), 1 )
   nStep  := iif( nFirst <= nLast, 1, -1 )
   FOR nLine = nFirst TO nLast STEP nStep
      aField := hb_ATokens( aLines[ nLine ], cDelim )
      cFields := AllTrim( cFields )
      DO CASE
      CASE Empty( cFields ) .OR. cFields == "0"
         aFieldList := {}
         FOR nField = 1 TO Len( aField )
            AAdd( aFieldList, nField )
         NEXT
      CASE "-" $ cFields
         nPos := At( "-", cFields )
         aFieldList := {}
         FOR nField = Val( cFields ) TO Val( Substr( cFields, nPos + 1 ) ) STEP iif( Val( cFields ) <= Val( Substr( cFields, nPos + 1 ) ), 1, -1 )
            AAdd( aFieldList, nField )
         NEXT
      OTHERWISE
         aFieldList := RmcArray( StrTran( cFields, ",", "*" ) )
      ENDCASE
      FOR EACH nField IN aFieldList
         IF nField >= 1 .AND. nField <= Len( aField )
            AAdd( aList, Val( aField[ nField ] ) )
         ENDIF
      NEXT
   NEXT

   RETURN aList

// line number, negative counts from the end (-1 = last line)
STATIC FUNCTION RmcLine( nLine, nCount )

   RETURN iif( nLine < 0, nCount + nLine + 1, iif( nLine == 0, nCount, nLine ) )

STATIC FUNCTION RmcLoad( cRMCFile, hRmc, cPath )

   LOCAL cText, cField

   IF ! HB_ISSTRING( cRMCFile ) .OR. Empty( cRMCFile )
      RETURN .F.
   ENDIF
   IF "|" $ cRMCFile
      cText := cRMCFile
      cPath := ""
   ELSE
      IF ! File( cRMCFile )
         RETURN .F.
      ENDIF
      cText := hb_MemoRead( cRMCFile )
      cPath := hb_FNameDir( cRMCFile )
   ENDIF
   cText := StrTran( StrTran( cText, Chr( 13 ), "" ), Chr( 10 ), "" )
   hRmc  := { => }
   FOR EACH cField IN hb_ATokens( cText, "|" )
      IF Len( cField ) >= 5 .AND. IsDigit( cField )
         hRmc[ Val( Left( cField, 5 ) ) ] := Substr( cField, 6 )
      ENDIF
   NEXT

   RETURN ! Empty( hRmc )

// file of the chart (image, data) relative to the *.rmc folder
STATIC FUNCTION RmcFile( cFile, cPath )

   IF Empty( cFile ) .OR. Empty( cPath ) .OR. File( cFile ) .OR. ":" $ cFile .OR. Left( cFile, 1 ) $ "\/"
      RETURN cFile
   ENDIF

   RETURN cPath + cFile

STATIC FUNCTION RmcArray( cText )

   LOCAL aList := {}, cItem

   IF ! Empty( cText )
      FOR EACH cItem IN hb_ATokens( cText, "*" )
         AAdd( aList, Val( cItem ) )
      NEXT
   ENDIF

   RETURN aList

STATIC FUNCTION RmcN( hRmc, nCode )

   RETURN iif( hb_HHasKey( hRmc, nCode ), Val( hRmc[ nCode ] ), 0 )

STATIC FUNCTION RmcC( hRmc, nCode )

   RETURN iif( hb_HHasKey( hRmc, nCode ), hRmc[ nCode ], "" )

/*
RMC_File2Source( cRMCFile, [bText], [bData] ) --> cSource
   Harbour source with the same RMC_*() calls that RMC_CreateChartFromFile() does,
   using the variables hWnd, nId and lExportOnly. Data from *.csv goes into the source.
   bText( cText ) --> cText    optional, to change the texts (captions, legends, labels)
   bData( aData, cFunc ) --> aData   optional, to change the data of the series
*/
FUNCTION RMC_File2Source( cRMCFile, bText, bData )

   LOCAL cSource

   s_hSource := { "code" => "", "text" => bText, "data" => bData }
   RMC_CreateChartFromFile( "hWnd", "nId", 0, 0, "lExportOnly", cRMCFile )
   cSource := s_hSource[ "code" ]
   s_hSource := Nil

   RETURN cSource

// draw (call the function) or, inside RMC_File2Source(), write the call as source
STATIC FUNCTION RmcDo( cFunc, ... )

   LOCAL aParams := hb_AParams(), xValue, cLine, nPos, lData

   hb_ADel( aParams, 1, .T. )
   IF s_hSource == Nil
      RETURN hb_ExecFromArray( cFunc, aParams )
   ENDIF
   cLine := "   " + cFunc + "( "
   FOR nPos = 1 TO Len( aParams )
      xValue := aParams[ nPos ]
      lData  := ( nPos == 3 .AND. ! cFunc $ "RMC_CreateChart,RMC_AddRegion,RMC_SetSeriesColor" ) .OR. ;
         ( nPos == 5 .AND. cFunc == "RMC_AddXYSeries" )
      DO CASE
      CASE HB_ISSTRING( xValue ) .AND. xValue $ "hWnd,nId,lExportOnly"
         cLine += xValue
      CASE HB_ISSTRING( xValue )
         IF s_hSource[ "text" ] != Nil .AND. ! cFunc == "RMC_CreateChart"
            xValue := Eval( s_hSource[ "text" ], xValue )
         ENDIF
         cLine += hb_ValToExp( xValue )
      CASE HB_ISARRAY( xValue )
         IF lData .AND. s_hSource[ "data" ] != Nil
            xValue := Eval( s_hSource[ "data" ], xValue, cFunc )
            aParams[ nPos + 1 ] := Len( xValue )
         ENDIF
         cLine += RmcArraySource( xValue )
      CASE HB_ISNUMERIC( xValue ) .AND. xValue == Int( xValue )
         cLine += hb_ntos( xValue )
      OTHERWISE
         cLine += hb_ValToExp( xValue )
      ENDCASE
      cLine += iif( nPos == Len( aParams ), " )", ", " )
   NEXT
   s_hSource[ "code" ] += cLine + hb_Eol()

   RETURN 0

// array as source, 10 values by line
STATIC FUNCTION RmcArraySource( aList )

   LOCAL cText := "{ ", nPos

   FOR nPos = 1 TO Len( aList )
      cText += iif( HB_ISNUMERIC( aList[ nPos ] ) .AND. aList[ nPos ] != Int( aList[ nPos ] ), ;
         hb_ntos( Round( aList[ nPos ], 4 ) ), hb_ValToExp( aList[ nPos ] ) )
      IF nPos < Len( aList )
         cText += iif( nPos % 10 == 0, ", ;" + hb_Eol() + "      ", ", " )
      ENDIF
   NEXT

   RETURN cText + " }"
