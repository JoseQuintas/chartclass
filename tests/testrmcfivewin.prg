/*
TESTRMCFIVEWIN - FiveWin window with tabs, one tab for each chart of rmcsamples.prg
*/

#include "FiveWin.Ch"

FUNCTION Main()

   LOCAL oDlg, oFld

   FW_SetTruePixel( .T. )

   DEFINE DIALOG oDlg TITLE "FiveWin - chartclass - rmcsamples" SIZE 1024, 748 PIXEL

   @ 0, 0 FOLDEREX oFld PROMPT "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23" ;
      SIZE 900, 700 OF oDlg PIXEL

   ACTIVATE DIALOG oDlg CENTER ON INIT ( (Self), DrawAll( oFld ) )

   RETURN NIL

STATIC FUNCTION DrawAll( oFld )

   LOCAL nCont, oChart := ChartClass():New(), nId

   FOR nCont = 1 TO RmcSampleCount()
      nId := oChart:GetChartId()
      RmcSample( nCont, oFld:aDialogs[ nCont ]:hWnd, nId, .F. )
      oChart:Draw( nId )
   NEXT

   RETURN Nil
