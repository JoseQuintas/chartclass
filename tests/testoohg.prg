/*
TESTOOHG - OOHG window with TAB, one chart on a LABEL of each page

hbmk2 testoohg.hbp
*/

#include "ze_chartclass.ch"
#include "oohg.ch"

#define MAX_SIZE_ONE 800
#define MAX_SIZE_TWO 600

FUNCTION Main()

   LOCAL nCont

   DEFINE WINDOW Main ;
      AT 0, 0 ;
      WIDTH 1024 ;
      HEIGHT 748 ;
      TITLE "OOHG - chartclass" ;
      MAIN ;
      ON INIT DrawAll()

      DEFINE TAB Tab1 ;
         AT 5, 5 ;
         WIDTH 900 ;
         HEIGHT 700

         FOR nCont = 1 TO 16
            DEFINE PAGE Chr( 64 + nCont )
               // page is not a window, the chart goes on a label of the page
               @ 40, 40 LABEL ( "Chart" + Ltrim( Str( nCont ) ) ) VALUE "" WIDTH MAX_SIZE_ONE HEIGHT MAX_SIZE_TWO
            END PAGE
         NEXT

      END TAB

   END WINDOW

   CENTER WINDOW Main
   ACTIVATE WINDOW Main

   RETURN NIL

FUNCTION DrawAll()

   Graphic1(  ChartHandle( 1 ) )
   Graphic2(  ChartHandle( 2 ) )
   Graphic3(  ChartHandle( 3 ) )
   Graphic4(  ChartHandle( 4 ) )
   Graphic5(  ChartHandle( 5 ) )
   Graphic6(  ChartHandle( 6 ) )
   Graphic7(  ChartHandle( 7 ) )
   Graphic8(  ChartHandle( 8 ) )
   Graphic9(  ChartHandle( 9 ) )
   Graphic10( ChartHandle( 10 ) )
   Graphic11( ChartHandle( 11 ), MAX_SIZE_ONE, MAX_SIZE_TWO )
   Graphic12( ChartHandle( 12 ), MAX_SIZE_ONE, MAX_SIZE_TWO )
   Graphic13( ChartHandle( 13 ), MAX_SIZE_ONE, MAX_SIZE_TWO )
   Graphic14( ChartHandle( 14 ), MAX_SIZE_ONE, MAX_SIZE_TWO )
   Graphic15( ChartHandle( 15 ), MAX_SIZE_ONE, MAX_SIZE_TWO )
   Graphic16( ChartHandle( 16 ), MAX_SIZE_ONE, MAX_SIZE_TWO )

   RETURN Nil

STATIC FUNCTION ChartHandle( nCont )

   RETURN GetControlObject( "Chart" + Ltrim( Str( nCont ) ), "Main" ):hWnd
