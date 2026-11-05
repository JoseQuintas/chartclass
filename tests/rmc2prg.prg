/*
RMC2PRG - *.rmc files to Harbour source (tests/rmcsamples.prg)
2026.11 José Quintas

rmc2prg <folder with *.rmc> <output.prg>
Texts and data are changed by fictitious ones (the *.rmc samples are not part of chartclass),
only the kind of chart is the same. Custom objects (RMC_CO*) are not converted yet.
*/

#include "directry.ch"

STATIC s_nText := 0

PROCEDURE Main( cFolder, cOutput )

   LOCAL aFiles, aFile, cSource := "", nCont := 0, cCode, cList := "", cPath

   hb_Default( @cFolder, "." )
   hb_Default( @cOutput, "rmcsamples.prg" )
   cPath  := hb_DirSepAdd( cFolder )
   aFiles := ASort( Directory( cPath + "*.rmc" ),,, {| a, b | Upper( a[ F_NAME ] ) < Upper( b[ F_NAME ] ) } )
   FOR EACH aFile IN aFiles
      IF "FLOWCHART" $ Upper( aFile[ F_NAME ] ) // only custom objects
         LOOP
      ENDIF
      nCont++
      hb_RandomSeed( nCont )
      s_nText := 0
      cCode := RMC_File2Source( cPath + aFile[ F_NAME ], {| c | FakeText( c ) }, {| a, f | FakeData( a, f ) } )
      cCode := StrTran( cCode, hb_ValToExp( cPath ), '""' )
      cCode := StrTran( cCode, StrTran( hb_ValToExp( cPath ), "\", "\\" ), '""' )
      cCode := ImageName( cCode, cPath )
      cSource += hb_Eol() + "STATIC FUNCTION RmcSample" + StrZero( nCont, 2 ) + "( hWnd, nId, lExportOnly )" + hb_Eol() + hb_Eol() + ;
         cCode + hb_Eol() + "   RETURN Nil" + hb_Eol()
      cList += iif( nCont == 1, "", ", " ) + "@RmcSample" + StrZero( nCont, 2 ) + "()"
   NEXT
   cSource := "/*" + hb_Eol() + ;
      "RMCSAMPLES - " + hb_ntos( nCont ) + " samples with the kind of the RMChart *.rmc samples" + hb_Eol() + ;
      "texts and data are fictitious, created by tests/rmc2prg.prg" + hb_Eol() + hb_Eol() + ;
      "RmcSample( nSample, hWnd, nId, lExportOnly ) --> nil, creates the chart nId, call RMC_Draw() after" + hb_Eol() + ;
      "RmcSampleCount() --> number of samples" + hb_Eol() + ;
      "*/" + hb_Eol() + hb_Eol() + ;
      '#include "ze_chartclass.ch"' + hb_Eol() + hb_Eol() + ;
      "FUNCTION RmcSample( nSample, hWnd, nId, lExportOnly )" + hb_Eol() + hb_Eol() + ;
      "   LOCAL aList := { " + cList + " }" + hb_Eol() + hb_Eol() + ;
      "   RETURN aList[ nSample ]:Exec( hWnd, nId, lExportOnly )" + hb_Eol() + hb_Eol() + ;
      "FUNCTION RmcSampleCount()" + hb_Eol() + hb_Eol() + ;
      "   RETURN " + hb_ntos( nCont ) + hb_Eol() + ;
      cSource
   hb_MemoWrit( cOutput, cSource )
   ? cOutput, nCont, "samples"

   RETURN

// texts: lists "a*b*c" become Item names, other texts become Text n; \9b options are kept
STATIC FUNCTION FakeText( cText )

   LOCAL aList, cItem, cResult := "", cOption, nPos
   LOCAL aWords := { "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", ;
      "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon" }

   IF Empty( cText )
      RETURN cText
   ENDIF
   IF ! "*" $ cText
      cOption := ""
      IF ( nPos := RAt( "\", cText ) ) > 0
         cOption := Substr( cText, nPos )
         cText   := Left( cText, nPos - 1 )
      ENDIF
      IF Empty( cText ) .OR. ! HasLetter( cText )
         RETURN cText + cOption
      ENDIF
      RETURN "Sample text " + hb_ntos( ++s_nText ) + cOption
   ENDIF
   aList := hb_ATokens( cText, "*" )
   FOR EACH cItem IN aList
      IF HasLetter( cItem )
         cItem := aWords[ ( cItem:__EnumIndex() - 1 ) % Len( aWords ) + 1 ]
      ENDIF
      cResult += iif( cItem:__EnumIsFirst(), "", "*" ) + cItem
   NEXT

   RETURN cResult

STATIC FUNCTION HasLetter( cText )

   LOCAL nPos

   FOR nPos = 1 TO Len( cText )
      IF IsAlpha( Substr( cText, nPos, 1 ) )
         RETURN .T.
      ENDIF
   NEXT

   RETURN .F.

// data: random values in the same range, high-low with open/high/low/close coherent
STATIC FUNCTION FakeData( aData, cFunc )

   LOCAL nMin := 0, nMax := 0, lInt := .T., xValue, aNew := {}, nBase, nCont, nOpen, nClose, nRange

   FOR EACH xValue IN aData
      IF xValue:__EnumIsFirst()
         nMin := nMax := xValue
      ENDIF
      nMin := Min( nMin, xValue )
      nMax := Max( nMax, xValue )
      IF xValue != Int( xValue )
         lInt := .F.
      ENDIF
   NEXT
   nRange := nMax - nMin
   IF cFunc == "RMC_AddHighLowSeries"
      nBase := nMin + nRange / 2
      FOR nCont = 1 TO Int( Len( aData ) / 4 )
         nOpen  := nBase
         nClose := Max( nMin, Min( nMax, nBase + ( hb_Random() - 0.5 ) * nRange / 5 ) )
         AAdd( aNew, Round( nOpen, 2 ) )
         AAdd( aNew, Round( Max( nOpen, nClose ) + hb_Random() * nRange / 10, 2 ) )
         AAdd( aNew, Round( Min( nOpen, nClose ) - hb_Random() * nRange / 10, 2 ) )
         AAdd( aNew, Round( nClose, 2 ) )
         nBase := nClose
      NEXT
      RETURN aNew
   ENDIF
   nBase := nMin + nRange / 2
   FOR EACH xValue IN aData
      IF cFunc == "RMC_AddLineSeries" .AND. Len( aData ) > 20
         // many points: gradual change, as a real series
         nBase := Max( nMin, Min( nMax, nBase + ( hb_Random() - 0.5 ) * nRange / 8 ) )
         xValue := nBase
      ELSE
         xValue := nMin + hb_Random() * nRange
      ENDIF
      AAdd( aNew, iif( lInt, Int( xValue ), Round( xValue, 2 ) ) )
   NEXT

   RETURN aNew

// image of the chart: only the file name, and only images that chartclass already has in tests
STATIC FUNCTION ImageName( cCode, cPath )

   LOCAL cImage

   cCode := StrTran( cCode, cPath, "" )
   FOR EACH cImage IN { "paper.jpg" }
      cCode := StrTran( cCode, ["] + cImage + ["], [""] )
   NEXT

   RETURN cCode
