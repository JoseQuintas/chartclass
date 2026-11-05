/*
TESTRMCSAMPLES - draws tests/rmcsamples.prg to PNG files (rmcsample_01.png ...)
*/

PROCEDURE Main()

   LOCAL nSample, oChart := ChartClass():New(), nId, nW, nH

   FOR nSample = 1 TO RmcSampleCount()
      nId := oChart:GetChartId()
      RmcSample( nSample, 0, nId, .T. )
      nW := oChart:GetCtrlWidth( nId )
      nH := oChart:GetCtrlHeight( nId )
      oChart:Draw( nId )
      ? nSample, oChart:Draw2File( nId, "rmcsample_" + StrZero( nSample, 2 ) + ".png", nW, nH, 0 )
      oChart:DeleteChart( nId )
   NEXT

   RETURN
