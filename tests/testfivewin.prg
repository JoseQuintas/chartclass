
#include "ze_chartclass.ch"
#include "FiveWin.Ch"
#define MAX_SIZE_ONE 800
#DEFINE MAX_SIZE_TWO 600

FUNCTION MAIN()

   LOCAL oDlg, oFld

   FW_SetTruePixel( .T. )

   DEFINE DIALOG oDlg TITLE "FiveWin - chartclass" SIZE 1024, 748 PIXEL

   @ 0,0 FOLDEREX oFld PROMPT "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P" SIZE 900, 700 OF oDlg PIXEL

   ACTIVATE DIALOG oDlg CENTER ON INIT ( (Self), DrawAll( oFld ) )

   RETURN NIL

FUNCTION DrawAll( oFld )

   Graphic1(  oFld:aDialogs[1]:hWnd )
   Graphic2(  oFld:aDialogs[2]:hWnd )
   Graphic3(  oFld:aDialogs[3]:hWnd )
   Graphic4(  oFld:aDialogs[4]:hWnd )
   Graphic5(  oFld:aDialogs[5]:hWnd )
   Graphic6(  oFld:aDialogs[6]:hWnd )
   Graphic7(  oFld:aDialogs[7]:hWnd )
   Graphic8(  oFld:aDialogs[8]:hWnd )
   Graphic9(  oFld:aDialogs[9]:hWnd )
   Graphic10( oFld:aDialogs[10]:hWnd )
   Graphic11( oFld:aDialogs[11]:hWnd, MAX_SIZE_ONE, MAX_SIZE_TWO )
   Graphic12( oFld:aDialogs[12]:hWnd, MAX_SIZE_ONE, MAX_SIZE_TWO )
   Graphic13( oFld:aDialogs[13]:hWnd, MAX_SIZE_ONE, MAX_SIZE_TWO )
   Graphic14( oFld:aDialogs[14]:hWnd, MAX_SIZE_ONE, MAX_SIZE_TWO )
   Graphic15( oFld:aDialogs[15]:hWnd, MAX_SIZE_ONE, MAX_SIZE_TWO )
   Graphic16( oFld:aDialogs[16]:hWnd, MAX_SIZE_ONE, MAX_SIZE_TWO )

   RETURN Nil
