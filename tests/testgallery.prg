/*
TESTGALLERY - all samples to PNG files on ../images, used on README gallery
samples.prg (1 to 10), moresamples.prg (11 to 16) and rmcsamples.prg (23)
run from tests folder, samples use seasky.jpg

hbmk2 testgallery.hbp
*/

#include "ze_chartclass.ch"

#define IMAGE_WIDTH  800
#define IMAGE_HEIGHT 600

PROCEDURE Main()

   LOCAL aList, nCont, cPath := ".." + hb_ps() + "images" + hb_ps()
   LOCAL oChart := ChartClass():New(), nId

   hb_DirBuild( cPath )

   aList := { @Graphic1(), @Graphic2(), @Graphic3(), @Graphic4(), @Graphic5(), ;
              @Graphic6(), @Graphic7(), @Graphic8(), @Graphic9(), @Graphic10() }
   FOR nCont = 1 TO Len( aList )
      oChart:SetWatermark( "", 0, 0, 0, 0 ) // watermark is global, only sample 9 has one
      aList[ nCont ]:Exec( 0, cPath + "sample_" + StrZero( nCont, 2 ) + ".png" )
      ? "sample", nCont
   NEXT

   aList := { @Graphic11(), @Graphic12(), @Graphic13(), @Graphic14(), @Graphic15(), @Graphic16() }
   FOR nCont = 1 TO Len( aList )
      oChart:SetWatermark( "", 0, 0, 0, 0 ) // watermark is global, only sample 9 has one
      aList[ nCont ]:Exec( 0, IMAGE_WIDTH, IMAGE_HEIGHT, cPath + "sample_" + StrZero( nCont + 10, 2 ) + ".png" )
      ? "sample", nCont + 10
   NEXT

   FOR nCont = 1 TO RmcSampleCount()
      oChart:SetWatermark( "", 0, 0, 0, 0 )
      nId := oChart:GetChartId()
      RmcSample( nCont, 0, nId, .T. )
      oChart:Draw( nId )
      ? "rmcsample", nCont, oChart:Draw2File( nId, cPath + "rmcsample_" + StrZero( nCont, 2 ) + ".png", ;
         oChart:GetCtrlWidth( nId ), oChart:GetCtrlHeight( nId ), 0 )
      oChart:DeleteChart( nId )
   NEXT

   RETURN
