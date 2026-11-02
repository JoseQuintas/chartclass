
#include "ze_chartclass.ch"
#include "hwgui.Ch"
#define MAX_SIZE_ONE 800
#DEFINE MAX_SIZE_TWO 600

FUNCTION MAIN()

   LOCAL oDlg, oFld

   INIT DIALOG oDlg ;
      TITLE "hwgui - chartclass" SIZE 1024, 748

   @ 5, 5 TAB oFld ;
      ITEMS {} ;
      OF oDlg ;
      SIZE 900, 700 ;
      STYLE WS_CHILD + WS_VISIBLE

   ACTIVATE DIALOG oDlg CENTER ON ACTIVATE { || DrawAll( oFld ) }

   RETURN NIL

FUNCTION DrawAll( oFld )

   LOCAL oPanel

   oPanel := Array(16)

   BEGIN PAGE "A" OF oFld
      @ 40, 40 PANEL oPanel[1] OF oFld SIZE 900, 600
      Graphic1(  oPanel[1]:Handle )
   END PAGE OF oFld
   BEGIN PAGE "B" OF oFld
      @ 40, 40 PANEL oPanel[2] OF oFld SIZE 900, 600
      Graphic2(  oPanel[2]:Handle )
   END PAGE OF oFld
   BEGIN PAGE "C" OF oFld
      @ 40, 40 PANEL oPanel[3] OF oFld SIZE 900, 600
      Graphic3(  oPanel[3]:Handle )
   END PAGE OF oFld
   BEGIN PAGE "D" OF oFld
      @ 40, 40 PANEL oPanel[4] OF oFld SIZE 900, 600
      Graphic4(  oPanel[4]:Handle )
   END PAGE OF oFld
   BEGIN PAGE "E" OF oFld
      @ 40, 40 PANEL oPanel[5] OF oFld SIZE 900, 600
      Graphic5(  oPanel[5]:Handle )
   END PAGE OF oFld
   BEGIN PAGE "F" OF oFld
      @ 40, 40 PANEL oPanel[6] OF oFld SIZE 900, 600
      Graphic6(  oPanel[6]:Handle )
   END PAGE OF oFld
   BEGIN PAGE "G" OF oFld
      @ 40, 40 PANEL oPanel[7] OF oFld SIZE 900, 600
      Graphic7(  oPanel[7]:Handle )
   END PAGE OF oFld
   BEGIN PAGE "H" OF oFld
      @ 40, 40 PANEL oPanel[8] OF oFld SIZE 900, 600
      Graphic8(  oPanel[8]:Handle )
   END PAGE OF oFld
   BEGIN PAGE "I" OF oFld
      @ 40, 40 PANEL oPanel[9] OF oFld SIZE 900, 600
      Graphic9(  oPanel[9]:Handle )
   END PAGE OF oFld
   BEGIN PAGE "J" OF oFld
      @ 40, 40 PANEL oPanel[10] OF oFld SIZE 900, 600
      Graphic10( oPanel[10]:Handle )
   END PAGE OF oFld
   BEGIN PAGE "K" OF oFld
      @ 40, 40 PANEL oPanel[11] OF oFld SIZE 900, 600
      Graphic11( oPanel[11]:Handle, MAX_SIZE_ONE, MAX_SIZE_TWO )
   END PAGE OF oFld
   BEGIN PAGE "L" OF oFld
      @ 40, 40 PANEL oPanel[12] OF oFld SIZE 900, 600
      Graphic12( oPanel[12]:Handle, MAX_SIZE_ONE, MAX_SIZE_TWO )
   END PAGE OF oFld
   BEGIN PAGE "M" OF oFld
      @ 40, 40 PANEL oPanel[13] OF oFld SIZE 900, 600
      Graphic13( oPanel[13]:Handle, MAX_SIZE_ONE, MAX_SIZE_TWO )
   END PAGE OF oFld
   BEGIN PAGE "N" OF oFld
      @ 40, 40 PANEL oPanel[14] OF oFld SIZE 900, 600
      Graphic14( oPanel[14]:Handle, MAX_SIZE_ONE, MAX_SIZE_TWO )
   END PAGE OF oFld
   BEGIN PAGE "O" OF oFld
      @ 40, 40 PANEL oPanel[15] OF oFld SIZE 900, 600
      Graphic15( oPanel[15]:Handle, MAX_SIZE_ONE, MAX_SIZE_TWO )
   END PAGE OF oFld
   BEGIN PAGE "P" OF oFld
      @ 40, 40 PANEL oPanel[16] OF oFld SIZE 900, 600
      Graphic16( oPanel[16]:Handle, MAX_SIZE_ONE, MAX_SIZE_TWO )
   END PAGE OF oFld

   RETURN Nil
