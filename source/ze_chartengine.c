/*
ZE_CHARTENGINE - chart engine for chartclass, drawn with GDI+
2026.10 José Quintas

Written from scratch, inspired by RMChart, with a compatible RMC_* API.
gdiplus.dll is loaded on runtime (LoadLibrary/GetProcAddress), only the flat API,
to compile with MinGW, BCC and MSVC, 32 and 64 bits, without GDI+ headers.
*/

#include "hbapi.h"
#include "hbapiitm.h"
#include "hbapicdp.h"
#include "hbvm.h"

#include <windows.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

/* ---------------------------------------------------------------- GDI+ flat API */

typedef int     GpStatus;
typedef float   REAL;
typedef DWORD   ARGB;
typedef void    GpGraphics;
typedef void    GpBrush;
typedef void    GpPen;
typedef void    GpPath;
typedef void    GpFont;
typedef void    GpFontFamily;
typedef void    GpStringFormat;
typedef void    GpImage;

typedef struct
{
   UINT32 GdiplusVersion;
   void * DebugEventCallback;
   BOOL   SuppressBackgroundThread;
   BOOL   SuppressExternalCodecs;
} CHC_GDIPSTARTUPINPUT;

typedef struct
{
   REAL X, Y, Width, Height;
} CHC_RECTF;

typedef struct
{
   REAL X, Y;
} CHC_POINTF;

#define CHC_GDIP_FUNC( ret, name, args )  typedef ret ( WINAPI * PFN_##name ) args; static PFN_##name p##name = NULL;

CHC_GDIP_FUNC( GpStatus, GdiplusStartup, ( ULONG_PTR *, const CHC_GDIPSTARTUPINPUT *, void * ) )
CHC_GDIP_FUNC( void,     GdiplusShutdown, ( ULONG_PTR ) )
CHC_GDIP_FUNC( GpStatus, GdipCreateFromHDC, ( HDC, GpGraphics ** ) )
CHC_GDIP_FUNC( GpStatus, GdipDeleteGraphics, ( GpGraphics * ) )
CHC_GDIP_FUNC( GpStatus, GdipSetSmoothingMode, ( GpGraphics *, int ) )
CHC_GDIP_FUNC( GpStatus, GdipSetTextRenderingHint, ( GpGraphics *, int ) )
CHC_GDIP_FUNC( GpStatus, GdipSetPixelOffsetMode, ( GpGraphics *, int ) )
CHC_GDIP_FUNC( GpStatus, GdipGraphicsClear, ( GpGraphics *, ARGB ) )
CHC_GDIP_FUNC( GpStatus, GdipCreateSolidFill, ( ARGB, GpBrush ** ) )
CHC_GDIP_FUNC( GpStatus, GdipCreateLineBrushFromRect, ( const CHC_RECTF *, ARGB, ARGB, int, int, GpBrush ** ) )
CHC_GDIP_FUNC( GpStatus, GdipSetLineSigmaBlend, ( GpBrush *, REAL, REAL ) )
CHC_GDIP_FUNC( GpStatus, GdipCreateHatchBrush, ( int, ARGB, ARGB, GpBrush ** ) )
CHC_GDIP_FUNC( GpStatus, GdipCreateTexture, ( GpImage *, int, GpBrush ** ) )
CHC_GDIP_FUNC( GpStatus, GdipCreatePathGradientFromPath, ( const GpPath *, GpBrush ** ) )
CHC_GDIP_FUNC( GpStatus, GdipSetPathGradientCenterColor, ( GpBrush *, ARGB ) )
CHC_GDIP_FUNC( GpStatus, GdipSetPathGradientSurroundColorsWithCount, ( GpBrush *, const ARGB *, INT * ) )
CHC_GDIP_FUNC( GpStatus, GdipSetPathGradientCenterPoint, ( GpBrush *, const CHC_POINTF * ) )
CHC_GDIP_FUNC( GpStatus, GdipDeleteBrush, ( GpBrush * ) )
CHC_GDIP_FUNC( GpStatus, GdipCreatePen1, ( ARGB, REAL, int, GpPen ** ) )
CHC_GDIP_FUNC( GpStatus, GdipSetPenDashStyle, ( GpPen *, int ) )
CHC_GDIP_FUNC( GpStatus, GdipSetPenLineJoin, ( GpPen *, int ) )
CHC_GDIP_FUNC( GpStatus, GdipDeletePen, ( GpPen * ) )
CHC_GDIP_FUNC( GpStatus, GdipDrawLine, ( GpGraphics *, GpPen *, REAL, REAL, REAL, REAL ) )
CHC_GDIP_FUNC( GpStatus, GdipDrawRectangle, ( GpGraphics *, GpPen *, REAL, REAL, REAL, REAL ) )
CHC_GDIP_FUNC( GpStatus, GdipFillRectangle, ( GpGraphics *, GpBrush *, REAL, REAL, REAL, REAL ) )
CHC_GDIP_FUNC( GpStatus, GdipFillPolygon, ( GpGraphics *, GpBrush *, const CHC_POINTF *, INT, int ) )
CHC_GDIP_FUNC( GpStatus, GdipDrawPolygon, ( GpGraphics *, GpPen *, const CHC_POINTF *, INT ) )
CHC_GDIP_FUNC( GpStatus, GdipFillEllipse, ( GpGraphics *, GpBrush *, REAL, REAL, REAL, REAL ) )
CHC_GDIP_FUNC( GpStatus, GdipDrawEllipse, ( GpGraphics *, GpPen *, REAL, REAL, REAL, REAL ) )
CHC_GDIP_FUNC( GpStatus, GdipCreatePath, ( int, GpPath ** ) )
CHC_GDIP_FUNC( GpStatus, GdipDeletePath, ( GpPath * ) )
CHC_GDIP_FUNC( GpStatus, GdipAddPathArc, ( GpPath *, REAL, REAL, REAL, REAL, REAL, REAL ) )
CHC_GDIP_FUNC( GpStatus, GdipAddPathLine, ( GpPath *, REAL, REAL, REAL, REAL ) )
CHC_GDIP_FUNC( GpStatus, GdipAddPathPie, ( GpPath *, REAL, REAL, REAL, REAL, REAL, REAL ) )
CHC_GDIP_FUNC( GpStatus, GdipAddPathEllipse, ( GpPath *, REAL, REAL, REAL, REAL ) )
CHC_GDIP_FUNC( GpStatus, GdipClosePathFigure, ( GpPath * ) )
CHC_GDIP_FUNC( GpStatus, GdipFillPath, ( GpGraphics *, GpBrush *, GpPath * ) )
CHC_GDIP_FUNC( GpStatus, GdipDrawPath, ( GpGraphics *, GpPen *, GpPath * ) )
CHC_GDIP_FUNC( GpStatus, GdipCreateFontFamilyFromName, ( const WCHAR *, void *, GpFontFamily ** ) )
CHC_GDIP_FUNC( GpStatus, GdipGetGenericFontFamilySansSerif, ( GpFontFamily ** ) )
CHC_GDIP_FUNC( GpStatus, GdipDeleteFontFamily, ( GpFontFamily * ) )
CHC_GDIP_FUNC( GpStatus, GdipCreateFont, ( const GpFontFamily *, REAL, INT, int, GpFont ** ) )
CHC_GDIP_FUNC( GpStatus, GdipDeleteFont, ( GpFont * ) )
CHC_GDIP_FUNC( GpStatus, GdipCreateStringFormat, ( INT, LANGID, GpStringFormat ** ) )
CHC_GDIP_FUNC( GpStatus, GdipSetStringFormatAlign, ( GpStringFormat *, int ) )
CHC_GDIP_FUNC( GpStatus, GdipSetStringFormatLineAlign, ( GpStringFormat *, int ) )
CHC_GDIP_FUNC( GpStatus, GdipDeleteStringFormat, ( GpStringFormat * ) )
CHC_GDIP_FUNC( GpStatus, GdipDrawString, ( GpGraphics *, const WCHAR *, INT, const GpFont *, const CHC_RECTF *, const GpStringFormat *, const GpBrush * ) )
CHC_GDIP_FUNC( GpStatus, GdipMeasureString, ( GpGraphics *, const WCHAR *, INT, const GpFont *, const CHC_RECTF *, const GpStringFormat *, CHC_RECTF *, INT *, INT * ) )
CHC_GDIP_FUNC( GpStatus, GdipResetWorldTransform, ( GpGraphics * ) )
CHC_GDIP_FUNC( GpStatus, GdipTranslateWorldTransform, ( GpGraphics *, REAL, REAL, int ) )
CHC_GDIP_FUNC( GpStatus, GdipRotateWorldTransform, ( GpGraphics *, REAL, int ) )
CHC_GDIP_FUNC( GpStatus, GdipSetClipRect, ( GpGraphics *, REAL, REAL, REAL, REAL, int ) )
CHC_GDIP_FUNC( GpStatus, GdipResetClip, ( GpGraphics * ) )
CHC_GDIP_FUNC( GpStatus, GdipCreateBitmapFromScan0, ( INT, INT, INT, INT, BYTE *, GpImage ** ) )
CHC_GDIP_FUNC( GpStatus, GdipGetImageGraphicsContext, ( GpImage *, GpGraphics ** ) )
CHC_GDIP_FUNC( GpStatus, GdipSaveImageToFile, ( GpImage *, const WCHAR *, const CLSID *, const void * ) )
CHC_GDIP_FUNC( GpStatus, GdipLoadImageFromFile, ( const WCHAR *, GpImage ** ) )
CHC_GDIP_FUNC( GpStatus, GdipDisposeImage, ( GpImage * ) )
CHC_GDIP_FUNC( GpStatus, GdipDrawImageRectI, ( GpGraphics *, GpImage *, INT, INT, INT, INT ) )

#define CHC_GDIP_ENTRY( name )  { #name, ( FARPROC * ) &p##name }

static const struct
{
   const char * szName;
   FARPROC *    pFunc;
} s_gdipFuncs[] = {
   CHC_GDIP_ENTRY( GdiplusStartup ),
   CHC_GDIP_ENTRY( GdiplusShutdown ),
   CHC_GDIP_ENTRY( GdipCreateFromHDC ),
   CHC_GDIP_ENTRY( GdipDeleteGraphics ),
   CHC_GDIP_ENTRY( GdipSetSmoothingMode ),
   CHC_GDIP_ENTRY( GdipSetTextRenderingHint ),
   CHC_GDIP_ENTRY( GdipSetPixelOffsetMode ),
   CHC_GDIP_ENTRY( GdipGraphicsClear ),
   CHC_GDIP_ENTRY( GdipCreateSolidFill ),
   CHC_GDIP_ENTRY( GdipCreateLineBrushFromRect ),
   CHC_GDIP_ENTRY( GdipSetLineSigmaBlend ),
   CHC_GDIP_ENTRY( GdipCreateHatchBrush ),
   CHC_GDIP_ENTRY( GdipCreateTexture ),
   CHC_GDIP_ENTRY( GdipCreatePathGradientFromPath ),
   CHC_GDIP_ENTRY( GdipSetPathGradientCenterColor ),
   CHC_GDIP_ENTRY( GdipSetPathGradientSurroundColorsWithCount ),
   CHC_GDIP_ENTRY( GdipSetPathGradientCenterPoint ),
   CHC_GDIP_ENTRY( GdipDeleteBrush ),
   CHC_GDIP_ENTRY( GdipCreatePen1 ),
   CHC_GDIP_ENTRY( GdipSetPenDashStyle ),
   CHC_GDIP_ENTRY( GdipSetPenLineJoin ),
   CHC_GDIP_ENTRY( GdipDeletePen ),
   CHC_GDIP_ENTRY( GdipDrawLine ),
   CHC_GDIP_ENTRY( GdipDrawRectangle ),
   CHC_GDIP_ENTRY( GdipFillRectangle ),
   CHC_GDIP_ENTRY( GdipFillPolygon ),
   CHC_GDIP_ENTRY( GdipDrawPolygon ),
   CHC_GDIP_ENTRY( GdipFillEllipse ),
   CHC_GDIP_ENTRY( GdipDrawEllipse ),
   CHC_GDIP_ENTRY( GdipCreatePath ),
   CHC_GDIP_ENTRY( GdipDeletePath ),
   CHC_GDIP_ENTRY( GdipAddPathArc ),
   CHC_GDIP_ENTRY( GdipAddPathLine ),
   CHC_GDIP_ENTRY( GdipAddPathPie ),
   CHC_GDIP_ENTRY( GdipAddPathEllipse ),
   CHC_GDIP_ENTRY( GdipClosePathFigure ),
   CHC_GDIP_ENTRY( GdipFillPath ),
   CHC_GDIP_ENTRY( GdipDrawPath ),
   CHC_GDIP_ENTRY( GdipCreateFontFamilyFromName ),
   CHC_GDIP_ENTRY( GdipGetGenericFontFamilySansSerif ),
   CHC_GDIP_ENTRY( GdipDeleteFontFamily ),
   CHC_GDIP_ENTRY( GdipCreateFont ),
   CHC_GDIP_ENTRY( GdipDeleteFont ),
   CHC_GDIP_ENTRY( GdipCreateStringFormat ),
   CHC_GDIP_ENTRY( GdipSetStringFormatAlign ),
   CHC_GDIP_ENTRY( GdipSetStringFormatLineAlign ),
   CHC_GDIP_ENTRY( GdipDeleteStringFormat ),
   CHC_GDIP_ENTRY( GdipDrawString ),
   CHC_GDIP_ENTRY( GdipMeasureString ),
   CHC_GDIP_ENTRY( GdipResetWorldTransform ),
   CHC_GDIP_ENTRY( GdipTranslateWorldTransform ),
   CHC_GDIP_ENTRY( GdipRotateWorldTransform ),
   CHC_GDIP_ENTRY( GdipSetClipRect ),
   CHC_GDIP_ENTRY( GdipResetClip ),
   CHC_GDIP_ENTRY( GdipCreateBitmapFromScan0 ),
   CHC_GDIP_ENTRY( GdipGetImageGraphicsContext ),
   CHC_GDIP_ENTRY( GdipSaveImageToFile ),
   CHC_GDIP_ENTRY( GdipLoadImageFromFile ),
   CHC_GDIP_ENTRY( GdipDisposeImage ),
   CHC_GDIP_ENTRY( GdipDrawImageRectI )
};

/* GDI+ enums used here */
#define GP_SMOOTHINGANTIALIAS     4
#define GP_TEXTANTIALIASGRIDFIT   3
#define GP_PIXELOFFSETHALF        4
#define GP_UNITPIXEL              2
#define GP_UNITPOINT              3
#define GP_FILLALTERNATE          0
#define GP_FILLWINDING            1
#define GP_GRADIENTHORIZONTAL     0
#define GP_GRADIENTVERTICAL       1
#define GP_WRAPTILE               0
#define GP_WRAPTILEFLIPXY         3
#define GP_ALIGNNEAR              0
#define GP_ALIGNCENTER            1
#define GP_ALIGNFAR               2
#define GP_MATRIXAPPEND           1
#define GP_COMBINEREPLACE         0
#define GP_FONTREGULAR            0
#define GP_FONTBOLD               1
#define GP_FORMATNOWRAP           0x00001000
#define GP_FORMATNOCLIP           0x00004000
#define GP_PIXELFORMAT32BPPARGB   0x0026200A
#define GP_LINEJOINROUND          2

/* ---------------------------------------------------------------- RMC_* values */

#define RMC_COLOR_DEFAULT         0
#define RMC_COLOR_TRANSPARENT     ( ( ARGB ) -2 )

#define RMC_CTRLSTYLEFLAT         0
#define RMC_CTRLSTYLEFLATSHADOW   1
#define RMC_CTRLSTYLE3D           2
#define RMC_CTRLSTYLE3DLIGHT      3
#define RMC_CTRLSTYLEIMAGE        4
#define RMC_CTRLSTYLEIMAGETILED   5

#define RMC_BARSINGLE             1
#define RMC_BARGROUP              2
#define RMC_BARSTACKED            3
#define RMC_BARSTACKED100         4
#define RMC_FLOATINGBAR           5
#define RMC_FLOATINGBARGROUP      6

#define RMC_BAR_FLAT              1
#define RMC_BAR_FLAT_GRADIENT1    2
#define RMC_BAR_FLAT_GRADIENT2    3
#define RMC_BAR_HOVER             4
#define RMC_COLUMN_FLAT           5
#define RMC_BAR_3D                6
#define RMC_BAR_3D_GRADIENT       7
#define RMC_COLUMN_3D             8
#define RMC_COLUMN_3D_GRADIENT    9
#define RMC_COLUMN_FLUTED         10

#define RMC_PIE_FLAT              51
#define RMC_PIE_GRADIENT          52
#define RMC_PIE_3D                53
#define RMC_PIE_3D_GRADIENT       54
#define RMC_DONUT_FLAT            55
#define RMC_DONUT_GRADIENT        56
#define RMC_DONUT_3D              57
#define RMC_DONUT_3D_GRADIENT     58
#define RMC_PYRAMIDE              59
#define RMC_PYRAMIDE3             60

#define RMC_FULL                  1
#define RMC_HALF_TOP              2
#define RMC_HALF_RIGHT            3
#define RMC_HALF_BOTTOM           4
#define RMC_HALF_LEFT             5

#define RMC_HATCHBRUSH_ON         1

#define RMC_DATAAXISLEFT          1
#define RMC_DATAAXISRIGHT         2
#define RMC_DATAAXISTOP           3
#define RMC_DATAAXISBOTTOM        4
#define RMC_LABELAXISLEFT         5
#define RMC_LABELAXISRIGHT        6
#define RMC_LABELAXISTOP          7
#define RMC_LABELAXISBOTTOM       8

#define RMC_LINESTYLESOLID        0
#define RMC_LINESTYLEDASH         1
#define RMC_LINESTYLEDOT          2
#define RMC_LINESTYLEDASHDOT      3
#define RMC_LINESTYLENONE         6

#define RMC_TEXTCENTER            0
#define RMC_TEXTLEFT              1
#define RMC_TEXTRIGHT             2
#define RMC_TEXTDOWNWARD          3
#define RMC_TEXTUPWARD            4

#define RMC_LEGEND_NONE           -1
#define RMC_LEGEND_TOP            1
#define RMC_LEGEND_LEFT           2
#define RMC_LEGEND_RIGHT          3
#define RMC_LEGEND_BOTTOM         4
#define RMC_LEGEND_UL             5
#define RMC_LEGEND_UR             6
#define RMC_LEGEND_LL             7
#define RMC_LEGEND_LR             8
#define RMC_LEGEND_ONVLABELS      9
#define RMC_LEGEND_CUSTOM_TOP     11
#define RMC_LEGEND_CUSTOM_LEFT    12
#define RMC_LEGEND_CUSTOM_RIGHT   13
#define RMC_LEGEND_CUSTOM_BOTTOM  14
#define RMC_LEGEND_CUSTOM_UL      15
#define RMC_LEGEND_CUSTOM_UR      16
#define RMC_LEGEND_CUSTOM_LL      17
#define RMC_LEGEND_CUSTOM_LR      18
#define RMC_LEGEND_CUSTOM_CENTER  19
#define RMC_LEGEND_CUSTOM_CR      20
#define RMC_LEGEND_CUSTOM_CL      21

#define RMC_LEGENDNORECT          1
#define RMC_LEGENDRECT            2
#define RMC_LEGENDRECTSHADOW      3
#define RMC_LEGENDROUNDRECT       4
#define RMC_LEGENDROUNDRECTSHADOW 5

#define RMC_VLABEL_NONE           0
#define RMC_VLABEL_DEFAULT        1
#define RMC_VLABEL_PERCENT        5
#define RMC_VLABEL_ABSOLUTE       6
#define RMC_VLABEL_TWIN           7
#define RMC_VLABEL_LEGENDONLY     8

#define RMC_BICOLOR_NONE          0
#define RMC_BICOLOR_DATAAXIS      1
#define RMC_BICOLOR_LABELAXIS     2
#define RMC_BICOLOR_BOTH          3

#define RMC_EXPLODE_SMALLEST      -1
#define RMC_EXPLODE_BIGGEST       -2

#define RMC_NO_ERROR              0
#define RMC_ERROR_MAXINST         -1
#define RMC_ERROR_MAXREGION       -2
#define RMC_ERROR_MAXSERIES       -3
#define RMC_ERROR_ALLOC           -4
#define RMC_ERROR_NODATA          -5
#define RMC_ERROR_CTRLID          -6
#define RMC_ERROR_SERIESINDEX     -7
#define RMC_ERROR_CREATEBITMAP    -8
#define RMC_ERROR_WRONGREGION     -9
#define RMC_ERROR_CREATEWINDOW    -11
#define RMC_ERROR_INIGDIP         -12
#define RMC_ERROR_NOGDIP          -14
#define RMC_ERROR_FILECREATE      -26
#define RMC_ERROR_AXISALIGNMENT   -29

/* ---------------------------------------------------------------- chart data */

#define CHC_MAXCHART    256
#define CHC_MAXREGION   32
#define CHC_MAXSERIES   64
#define CHC_MAXITEMS    1024

#define CHC_SER_BAR       1
#define CHC_SER_LINE      2
#define CHC_SER_GRIDLESS  3
#define CHC_SER_OTHER     9

#define CHC_DEFAULTFONT   "Tahoma"
#define CHC_CLASSNAME     L"CHARTCLASS_CTRL"

typedef struct
{
   int      iKind;
   double * pData;
   int      nData;
   ARGB *   pColors;          /* colors by point, 0 = series color */
   int      nColors;
   int      iType;
   int      iStyle;
   int      iAlign;
   int      iExplode;
   int      iVLabel;
   int      iHatch;
   int      iAxis;
   double   dStartAngle;
   ARGB     color;
   HB_BOOL  lLucent;
   HB_BOOL  lHorizontal;
   HB_BOOL  lHide;
} CHC_SERIES;

typedef struct
{
   HB_BOOL  lSet;
   int      iAlign;
   double   dMin;
   double   dMax;
   int      nTicks;
   int      iFontSize;
   ARGB     textColor;
   ARGB     lineColor;
   int      iLineStyle;
   int      nDecimals;
   char *   szUnit;
   char *   szText;
   char *   szLabels;
   int      iLabelAlign;
} CHC_DAXIS;

typedef struct
{
   HB_BOOL  lSet;
   char *   szLabels;
   int      nStart;
   int      nCount;
   int      iAlign;
   int      iFontSize;
   ARGB     textColor;
   int      iTextAlign;
   ARGB     lineColor;
   int      iLineStyle;
   char *   szText;
} CHC_LAXIS;

typedef struct
{
   HB_BOOL  lSet;
   char *   szText;
   ARGB     bgColor;
   ARGB     textColor;
   int      iFontSize;
   HB_BOOL  lBold;
} CHC_CAPTION;

typedef struct
{
   HB_BOOL  lSet;
   ARGB     bgColor;
   HB_BOOL  lGradient;
   int      iLeft;
   int      iTop;
   int      iWidth;
   int      iHeight;
   int      iBicolor;
} CHC_GRID;

typedef struct
{
   HB_BOOL  lSet;
   HB_BOOL  lHide;
   char *   szText;
   int      iAlign;
   ARGB     bgColor;
   int      iStyle;
   ARGB     textColor;
   int      iFontSize;
   HB_BOOL  lBold;
} CHC_LEGEND;

typedef struct
{
   int         x, y, w, h;
   char *      szFooter;
   HB_BOOL     lBorder;
   CHC_CAPTION caption;
   CHC_GRID    grid;
   CHC_DAXIS   daxis[ 2 ];
   int         nDAxis;
   CHC_LAXIS   laxis;
   CHC_LEGEND  legend;
   CHC_SERIES  series[ CHC_MAXSERIES ];
   int         nSeries;
} CHC_REGION;

typedef struct
{
   int         iId;
   HWND        hParent;
   HWND        hWnd;
   int         x, y, w, h;
   ARGB        bgColor;
   int         iStyle;
   HB_BOOL     lExport;
   char *      szImage;
   char *      szFont;
   int         iTipWidth;
   ARGB        bmpBgColor;
   CHC_REGION  region[ CHC_MAXREGION ];
   int         nRegion;
   HDC         hTargetDC;       /* RMC_CreateChartOnDC() */
   HDC         hMemDC;
   HBITMAP     hBitmap;
   HBITMAP     hOldBitmap;
   int         bmpW, bmpH;
} CHC_CHART;

typedef struct
{
   GpGraphics *   g;
   CHC_CHART *    pChart;
   GpFontFamily * family;
   int            iWidth;
   int            iHeight;
} CHC_DC;

static CHC_CHART * s_charts[ CHC_MAXCHART ];
static HMODULE     s_hGdip      = NULL;
static ULONG_PTR   s_gdipToken  = 0;
static HB_BOOL     s_lGdipOk    = HB_FALSE;
static HB_BOOL     s_lClassOk   = HB_FALSE;

static char *      s_szWaterMark = NULL;
static ARGB        s_wmColor     = 0xFF000000;
static int         s_wmLucent    = 30;
static int         s_wmAlign     = RMC_TEXTCENTER;
static int         s_wmFontSize  = 0;

/* number format, without locale */
static char        s_szDecimal[ 8 ]   = ",";
static char        s_szThousand[ 8 ]  = ".";
static char        s_szSuffix[ 32 ]   = "";

/* default colors, by series or by slice */
static const ARGB s_palette[] = {
   0xFF2F6EBA, 0xFF3FA34D, 0xFFD2483C, 0xFFE8A030, 0xFF8E5BB5, 0xFF1BA3A8,
   0xFFD35F9C, 0xFF7A8B99, 0xFF6B8E23, 0xFF4A4A8F, 0xFFB5651D, 0xFF5DADE2 };

#define CHC_PALETTE( n )  s_palette[ ( n ) % ( sizeof( s_palette ) / sizeof( ARGB ) ) ]

/* ---------------------------------------------------------------- GDI+ start/stop */

static void chc_GdipShutdown( void * cargo )
{
   int n;

   HB_SYMBOL_UNUSED( cargo );

   for( n = 0; n < CHC_MAXCHART; n++ )
   {
      if( s_charts[ n ] )
      {
         CHC_CHART * pChart = s_charts[ n ];
         if( pChart->hMemDC )
         {
            SelectObject( pChart->hMemDC, pChart->hOldBitmap );
            DeleteObject( pChart->hBitmap );
            DeleteDC( pChart->hMemDC );
            pChart->hMemDC = NULL;
         }
      }
   }
   if( s_lGdipOk )
   {
      pGdiplusShutdown( s_gdipToken );
      s_lGdipOk = HB_FALSE;
   }
   if( s_hGdip )
   {
      FreeLibrary( s_hGdip );
      s_hGdip = NULL;
   }
}

static int chc_GdipStartup( void )
{
   CHC_GDIPSTARTUPINPUT input;
   HB_SIZE n;

   if( s_lGdipOk )
      return RMC_NO_ERROR;

   if( s_hGdip == NULL )
   {
      s_hGdip = LoadLibraryW( L"gdiplus.dll" );
      if( s_hGdip == NULL )
         return RMC_ERROR_NOGDIP;
      for( n = 0; n < HB_SIZEOFARRAY( s_gdipFuncs ); n++ )
      {
         *s_gdipFuncs[ n ].pFunc = GetProcAddress( s_hGdip, s_gdipFuncs[ n ].szName );
         if( *s_gdipFuncs[ n ].pFunc == NULL )
         {
            FreeLibrary( s_hGdip );
            s_hGdip = NULL;
            return RMC_ERROR_NOGDIP;
         }
      }
   }
   memset( &input, 0, sizeof( input ) );
   input.GdiplusVersion = 1;
   if( pGdiplusStartup( &s_gdipToken, &input, NULL ) != 0 )
      return RMC_ERROR_INIGDIP;
   s_lGdipOk = HB_TRUE;
   hb_vmAtQuit( chc_GdipShutdown, NULL );

   return RMC_NO_ERROR;
}

/* ---------------------------------------------------------------- helpers */

static char * chc_StrDup( const char * szText )
{
   return hb_strdup( szText ? szText : "" );
}

static void chc_StrSet( char ** pszDest, const char * szText )
{
   if( *pszDest )
      hb_xfree( *pszDest );
   *pszDest = chc_StrDup( szText );
}

static void chc_StrFree( char ** pszText )
{
   if( *pszText )
   {
      hb_xfree( *pszText );
      *pszText = NULL;
   }
}

/* text to UTF-16, ANSI codepage like the original DLL, or UTF-8 when HVM uses it */
static WCHAR * chc_Wide( const char * szText, int * piLen )
{
   UINT    uiCP = CP_ACP;
   int     iLen;
   WCHAR * wText;
   PHB_CODEPAGE cdp = hb_vmCDP();

   if( szText == NULL )
      szText = "";
   if( cdp && hb_cdpIsUTF8( cdp ) )
      uiCP = CP_UTF8;
   iLen  = MultiByteToWideChar( uiCP, 0, szText, -1, NULL, 0 );
   wText = ( WCHAR * ) hb_xgrab( ( iLen + 1 ) * sizeof( WCHAR ) );
   MultiByteToWideChar( uiCP, 0, szText, -1, wText, iLen );
   wText[ iLen ] = 0;
   if( piLen )
      *piLen = ( int ) wcslen( wText );

   return wText;
}

/* item n (0 based) from list separated by "*" */
static int chc_ListCount( const char * szList )
{
   int nCount = 1;

   if( szList == NULL || *szList == '\0' )
      return 0;
   while( *szList )
   {
      if( *szList == '*' )
         nCount++;
      szList++;
   }
   return nCount;
}

static void chc_ListItem( const char * szList, int nItem, char * szDest, int iSize )
{
   int n = 0;

   *szDest = '\0';
   if( szList == NULL )
      return;
   while( nItem > 0 && *szList )
   {
      if( *szList == '*' )
         nItem--;
      szList++;
   }
   if( nItem > 0 )
      return;
   while( *szList && *szList != '*' && n < iSize - 1 )
      szDest[ n++ ] = *szList++;
   szDest[ n ] = '\0';
}

/* parameter helpers, values from Harbour arrays or binary strings (old ToDouble()/ToLong()) */
static HB_BOOL chc_parl( int iParam )
{
   if( HB_ISLOG( iParam ) )
      return hb_parl( iParam );
   return hb_parni( iParam ) != 0;
}

static ARGB chc_parcolor( int iParam )
{
   return ( ARGB ) ( HB_U32 ) hb_parnl( iParam );
}

static double * chc_pardoubles( int iParam, int * pnCount )
{
   double * pData = NULL;
   int      nCount = *pnCount, n;

   if( HB_ISARRAY( iParam ) )
   {
      PHB_ITEM pArray = hb_param( iParam, HB_IT_ARRAY );
      int nLen = ( int ) hb_arrayLen( pArray );
      if( nCount <= 0 || nCount > nLen )
         nCount = nLen;
      if( nCount > 0 )
      {
         pData = ( double * ) hb_xgrab( sizeof( double ) * nCount );
         for( n = 0; n < nCount; n++ )
            pData[ n ] = hb_arrayGetND( pArray, n + 1 );
      }
   }
   else if( HB_ISCHAR( iParam ) )
   {
      int nLen = ( int ) ( hb_parclen( iParam ) / sizeof( double ) );
      if( nCount <= 0 || nCount > nLen )
         nCount = nLen;
      if( nCount > 0 )
      {
         pData = ( double * ) hb_xgrab( sizeof( double ) * nCount );
         memcpy( pData, hb_parc( iParam ), sizeof( double ) * nCount );
      }
   }
   else if( HB_ISNUM( iParam ) )
   {
      nCount = 1;
      pData = ( double * ) hb_xgrab( sizeof( double ) );
      pData[ 0 ] = hb_parnd( iParam );
   }
   *pnCount = pData ? nCount : 0;

   return pData;
}

static ARGB * chc_parcolors( int iParam, int * pnCount )
{
   ARGB * pData = NULL;
   int    nCount = *pnCount, n;

   if( HB_ISARRAY( iParam ) )
   {
      PHB_ITEM pArray = hb_param( iParam, HB_IT_ARRAY );
      int nLen = ( int ) hb_arrayLen( pArray );
      if( nCount <= 0 || nCount > nLen )
         nCount = nLen;
      if( nCount > 0 )
      {
         pData = ( ARGB * ) hb_xgrab( sizeof( ARGB ) * nCount );
         for( n = 0; n < nCount; n++ )
            pData[ n ] = ( ARGB ) ( HB_U32 ) hb_arrayGetNL( pArray, n + 1 );
      }
   }
   else if( HB_ISCHAR( iParam ) )
   {
      int nLen = ( int ) ( hb_parclen( iParam ) / 4 );
      if( nCount <= 0 || nCount > nLen )
         nCount = nLen;
      if( nCount > 0 )
      {
         pData = ( ARGB * ) hb_xgrab( sizeof( ARGB ) * nCount );
         memcpy( pData, hb_parc( iParam ), sizeof( ARGB ) * nCount );
      }
   }
   *pnCount = pData ? nCount : 0;

   return pData;
}

static HWND chc_parhwnd( int iParam )
{
   if( HB_ISPOINTER( iParam ) )
      return ( HWND ) hb_parptr( iParam );
   return ( HWND ) ( HB_PTRUINT ) hb_parnint( iParam );
}

/* ---------------------------------------------------------------- colors */

static HB_BOOL chc_IsTransparent( ARGB color )
{
   return color == RMC_COLOR_TRANSPARENT || ( color >> 24 ) == 0;
}

/* 0 = default, positive values without alpha are RGB */
static ARGB chc_Color( ARGB color, ARGB defColor )
{
   if( color == RMC_COLOR_DEFAULT )
      return defColor;
   if( color == RMC_COLOR_TRANSPARENT )
      return 0x00FFFFFF;
   if( ( color >> 24 ) == 0 )
      return 0xFF000000 | color;
   return color;
}

static ARGB chc_Mix( ARGB color, ARGB target, double dFactor )
{
   int a = ( int ) ( color >> 24 ) & 0xFF;
   int r = ( int ) ( color >> 16 ) & 0xFF;
   int g = ( int ) ( color >> 8 ) & 0xFF;
   int b = ( int ) color & 0xFF;
   int tr = ( int ) ( target >> 16 ) & 0xFF;
   int tg = ( int ) ( target >> 8 ) & 0xFF;
   int tb = ( int ) target & 0xFF;

   r = r + ( int ) ( ( tr - r ) * dFactor );
   g = g + ( int ) ( ( tg - g ) * dFactor );
   b = b + ( int ) ( ( tb - b ) * dFactor );

   return ( ( ARGB ) a << 24 ) | ( ( ARGB ) r << 16 ) | ( ( ARGB ) g << 8 ) | ( ARGB ) b;
}

#define chc_Light( c, f )  chc_Mix( ( c ), 0xFFFFFFFF, ( f ) )
#define chc_Dark( c, f )   chc_Mix( ( c ), 0xFF000000, ( f ) )

static ARGB chc_Alpha( ARGB color, int iAlpha )
{
   return ( color & 0x00FFFFFF ) | ( ( ARGB ) ( iAlpha & 0xFF ) << 24 );
}

static ARGB chc_Contrast( ARGB color )
{
   int r = ( int ) ( color >> 16 ) & 0xFF;
   int g = ( int ) ( color >> 8 ) & 0xFF;
   int b = ( int ) color & 0xFF;

   return ( r * 299 + g * 587 + b * 114 ) / 1000 > 150 ? 0xFF000000 : 0xFFFFFFFF;
}

/* ---------------------------------------------------------------- drawing primitives */

static GpBrush * chc_Solid( ARGB color )
{
   GpBrush * brush = NULL;

   pGdipCreateSolidFill( color, &brush );
   return brush;
}

static GpPen * chc_Pen( ARGB color, REAL width, int iLineStyle )
{
   GpPen * pen = NULL;

   pGdipCreatePen1( color, width, GP_UNITPIXEL, &pen );
   switch( iLineStyle )
   {
      case RMC_LINESTYLEDASH:    pGdipSetPenDashStyle( pen, 1 ); break;
      case RMC_LINESTYLEDOT:     pGdipSetPenDashStyle( pen, 2 ); break;
      case RMC_LINESTYLEDASHDOT: pGdipSetPenDashStyle( pen, 3 ); break;
   }
   return pen;
}

static void chc_FillRect( CHC_DC * dc, ARGB color, REAL x, REAL y, REAL w, REAL h )
{
   GpBrush * brush;

   if( chc_IsTransparent( color ) || w <= 0 || h <= 0 )
      return;
   brush = chc_Solid( color );
   pGdipFillRectangle( dc->g, brush, x, y, w, h );
   pGdipDeleteBrush( brush );
}

static void chc_FillGradient( CHC_DC * dc, ARGB c1, ARGB c2, REAL x, REAL y, REAL w, REAL h, HB_BOOL lVertical, HB_BOOL lCenter )
{
   GpBrush * brush = NULL;
   CHC_RECTF rc;

   if( w <= 0 || h <= 0 )
      return;
   /* a bit larger, to avoid the wrap line on borders */
   rc.X = x - 1; rc.Y = y - 1; rc.Width = w + 2; rc.Height = h + 2;
   pGdipCreateLineBrushFromRect( &rc, c1, c2, lVertical ? GP_GRADIENTVERTICAL : GP_GRADIENTHORIZONTAL, GP_WRAPTILEFLIPXY, &brush );
   if( lCenter )
      pGdipSetLineSigmaBlend( brush, 0.5f, 1.0f );
   pGdipFillRectangle( dc->g, brush, x, y, w, h );
   pGdipDeleteBrush( brush );
}

static void chc_DrawRect( CHC_DC * dc, ARGB color, REAL x, REAL y, REAL w, REAL h )
{
   GpPen * pen;

   if( chc_IsTransparent( color ) )
      return;
   pen = chc_Pen( color, 1, RMC_LINESTYLESOLID );
   pGdipDrawRectangle( dc->g, pen, x + 0.5f, y + 0.5f, w - 1, h - 1 );
   pGdipDeletePen( pen );
}

static void chc_Line( CHC_DC * dc, ARGB color, int iLineStyle, REAL x1, REAL y1, REAL x2, REAL y2 )
{
   GpPen * pen;

   if( iLineStyle == RMC_LINESTYLENONE || chc_IsTransparent( color ) )
      return;
   pen = chc_Pen( color, 1, iLineStyle );
   pGdipDrawLine( dc->g, pen, x1 + 0.5f, y1 + 0.5f, x2 + 0.5f, y2 + 0.5f );
   pGdipDeletePen( pen );
}

static GpPath * chc_RoundRectPath( REAL x, REAL y, REAL w, REAL h, REAL r )
{
   GpPath * path = NULL;
   REAL d = r * 2;

   pGdipCreatePath( GP_FILLALTERNATE, &path );
   pGdipAddPathArc( path, x, y, d, d, 180, 90 );
   pGdipAddPathArc( path, x + w - d, y, d, d, 270, 90 );
   pGdipAddPathArc( path, x + w - d, y + h - d, d, d, 0, 90 );
   pGdipAddPathArc( path, x, y + h - d, d, d, 90, 90 );
   pGdipClosePathFigure( path );
   return path;
}

/* ---------------------------------------------------------------- text */

/* "text\9b" = 9 points bold, at end of text */
static void chc_TextFormat( const char * szText, char * szDest, int iSize, int * piFontSize, HB_BOOL * plBold )
{
   const char * pBack;

   hb_strncpy( szDest, szText ? szText : "", iSize - 1 );
   pBack = strrchr( szDest, '\\' );
   if( pBack && pBack[ 1 ] >= '0' && pBack[ 1 ] <= '9' )
   {
      const char * p = pBack + 1;
      int iFont = 0;

      while( *p >= '0' && *p <= '9' )
         iFont = iFont * 10 + ( *p++ - '0' );
      if( *p == 'b' || *p == 'B' )
      {
         *plBold = HB_TRUE;
         p++;
      }
      if( *p == '\0' )
      {
         if( iFont > 0 )
            *piFontSize = iFont;
         szDest[ pBack - szDest ] = '\0';
      }
   }
}

static GpFont * chc_Font( CHC_DC * dc, int iSize, HB_BOOL lBold )
{
   GpFont * font = NULL;

   if( iSize <= 0 )
      iSize = 8;
   pGdipCreateFont( dc->family, ( REAL ) iSize, lBold ? GP_FONTBOLD : GP_FONTREGULAR, GP_UNITPOINT, &font );
   return font;
}

static GpStringFormat * chc_Format( int iHAlign, int iVAlign )
{
   GpStringFormat * fmt = NULL;

   pGdipCreateStringFormat( GP_FORMATNOCLIP, 0, &fmt );
   pGdipSetStringFormatAlign( fmt, iHAlign );
   pGdipSetStringFormatLineAlign( fmt, iVAlign );
   return fmt;
}

static void chc_TextSize( CHC_DC * dc, const char * szText, int iSize, HB_BOOL lBold, REAL * pW, REAL * pH )
{
   CHC_RECTF layout, box;
   GpFont * font;
   GpStringFormat * fmt;
   WCHAR * wText;
   int iLen;

   *pW = 0;
   *pH = 0;
   font  = chc_Font( dc, iSize, lBold );
   fmt   = chc_Format( GP_ALIGNNEAR, GP_ALIGNNEAR );
   wText = chc_Wide( *szText ? szText : "Ag", &iLen );
   layout.X = 0; layout.Y = 0; layout.Width = 10000; layout.Height = 10000;
   memset( &box, 0, sizeof( box ) );
   pGdipMeasureString( dc->g, wText, iLen, font, &layout, fmt, &box, NULL, NULL );
   *pW = *szText ? box.Width : 0;
   *pH = box.Height;
   hb_xfree( wText );
   pGdipDeleteStringFormat( fmt );
   pGdipDeleteFont( font );
}

static void chc_TextRect( CHC_DC * dc, const char * szText, int iSize, HB_BOOL lBold, ARGB color, REAL x, REAL y, REAL w, REAL h, int iHAlign, int iVAlign )
{
   CHC_RECTF rc;
   GpFont * font;
   GpStringFormat * fmt;
   GpBrush * brush;
   WCHAR * wText;
   int iLen;

   if( szText == NULL || *szText == '\0' || chc_IsTransparent( color ) )
      return;
   font  = chc_Font( dc, iSize, lBold );
   fmt   = chc_Format( iHAlign, iVAlign );
   brush = chc_Solid( color );
   wText = chc_Wide( szText, &iLen );
   rc.X = x; rc.Y = y; rc.Width = w; rc.Height = h;
   pGdipDrawString( dc->g, wText, iLen, font, &rc, fmt, brush );
   hb_xfree( wText );
   pGdipDeleteBrush( brush );
   pGdipDeleteStringFormat( fmt );
   pGdipDeleteFont( font );
}

/* text centered on point, rotated */
static void chc_TextAngle( CHC_DC * dc, const char * szText, int iSize, HB_BOOL lBold, ARGB color, REAL cx, REAL cy, REAL fAngle )
{
   REAL w, h;

   if( szText == NULL || *szText == '\0' )
      return;
   chc_TextSize( dc, szText, iSize, lBold, &w, &h );
   if( fAngle == 0 )
   {
      chc_TextRect( dc, szText, iSize, lBold, color, cx - w / 2, cy - h / 2, w, h, GP_ALIGNCENTER, GP_ALIGNCENTER );
      return;
   }
   pGdipResetWorldTransform( dc->g );
   pGdipRotateWorldTransform( dc->g, fAngle, GP_MATRIXAPPEND );
   pGdipTranslateWorldTransform( dc->g, cx, cy, GP_MATRIXAPPEND );
   chc_TextRect( dc, szText, iSize, lBold, color, -w / 2, -h / 2, w, h, GP_ALIGNCENTER, GP_ALIGNCENTER );
   pGdipResetWorldTransform( dc->g );
}

/* number formatted by hand, without locale: prefix, thousand separator, decimals, suffix */
static void chc_FormatValue( double dValue, int nDecimals, const char * szUnit, char * szDest, int iSize )
{
   char   szDigits[ 64 ], szOut[ 128 ];
   double dScaled;
   int    nDigits = 0, n, j = 0, iInt, iLen;
   HB_BOOL lNeg = dValue < 0;

   if( nDecimals < 0 )
      nDecimals = 0;
   if( nDecimals > 6 )
      nDecimals = 6;
   dScaled = fabs( dValue );
   for( n = 0; n < nDecimals; n++ )
      dScaled *= 10;
   dScaled = floor( dScaled + 0.5 );
   if( dScaled > 1e17 )
      dScaled = 1e17;
   /* digits, from right to left */
   do
   {
      szDigits[ nDigits++ ] = ( char ) ( '0' + ( int ) fmod( dScaled, 10 ) );
      dScaled = floor( dScaled / 10 );
   }
   while( dScaled > 0 && nDigits < ( int ) sizeof( szDigits ) - 1 );
   while( nDigits <= nDecimals )
      szDigits[ nDigits++ ] = '0';
   iInt = nDigits - nDecimals;

   if( lNeg && ( nDigits > 1 || szDigits[ 0 ] != '0' ) )
      szOut[ j++ ] = '-';
   for( n = 0; n < iInt; n++ )
   {
      szOut[ j++ ] = szDigits[ nDigits - 1 - n ];
      if( ( iInt - n - 1 ) > 0 && ( iInt - n - 1 ) % 3 == 0 )
      {
         iLen = ( int ) strlen( s_szThousand );
         memcpy( szOut + j, s_szThousand, iLen );
         j += iLen;
      }
   }
   if( nDecimals > 0 )
   {
      iLen = ( int ) strlen( s_szDecimal );
      memcpy( szOut + j, s_szDecimal, iLen );
      j += iLen;
      for( n = nDecimals - 1; n >= 0; n-- )
         szOut[ j++ ] = szDigits[ n ];
   }
   szOut[ j ] = '\0';
   /* unit as prefix, without trailing spaces */
   hb_strncpy( szDest, szUnit ? szUnit : "", iSize - 1 );
   iLen = ( int ) strlen( szDest );
   while( iLen > 0 && szDest[ iLen - 1 ] == ' ' )
      szDest[ --iLen ] = 0;
   hb_strncat( szDest, szOut, iSize - 1 );
   hb_strncat( szDest, s_szSuffix, iSize - 1 );
}

/* ---------------------------------------------------------------- chart list */

static CHC_CHART * chc_ChartGet( int iId )
{
   int n;

   for( n = 0; n < CHC_MAXCHART; n++ )
   {
      if( s_charts[ n ] && s_charts[ n ]->iId == iId )
         return s_charts[ n ];
   }
   return NULL;
}

static CHC_REGION * chc_RegionGet( int iId, int iRegion )
{
   CHC_CHART * pChart = chc_ChartGet( iId );

   if( pChart == NULL || iRegion < 1 || iRegion > pChart->nRegion )
      return NULL;
   return &pChart->region[ iRegion - 1 ];
}

static void chc_SeriesFree( CHC_SERIES * pSeries )
{
   if( pSeries->pData )
      hb_xfree( pSeries->pData );
   if( pSeries->pColors )
      hb_xfree( pSeries->pColors );
   memset( pSeries, 0, sizeof( CHC_SERIES ) );
}

static void chc_RegionFree( CHC_REGION * pRegion )
{
   int n;

   chc_StrFree( &pRegion->szFooter );
   chc_StrFree( &pRegion->caption.szText );
   for( n = 0; n < 2; n++ )
   {
      chc_StrFree( &pRegion->daxis[ n ].szUnit );
      chc_StrFree( &pRegion->daxis[ n ].szText );
      chc_StrFree( &pRegion->daxis[ n ].szLabels );
   }
   chc_StrFree( &pRegion->laxis.szLabels );
   chc_StrFree( &pRegion->laxis.szText );
   chc_StrFree( &pRegion->legend.szText );
   for( n = 0; n < pRegion->nSeries; n++ )
      chc_SeriesFree( &pRegion->series[ n ] );
   memset( pRegion, 0, sizeof( CHC_REGION ) );
}

static void chc_ChartReset( CHC_CHART * pChart )
{
   int n;

   for( n = 0; n < pChart->nRegion; n++ )
      chc_RegionFree( &pChart->region[ n ] );
   pChart->nRegion = 0;
}

static void chc_ChartDelete( CHC_CHART * pChart )
{
   int n;

   chc_ChartReset( pChart );
   if( pChart->hWnd && IsWindow( pChart->hWnd ) )
   {
      SetWindowLongPtrW( pChart->hWnd, GWLP_USERDATA, 0 );
      DestroyWindow( pChart->hWnd );
   }
   if( pChart->hMemDC )
   {
      SelectObject( pChart->hMemDC, pChart->hOldBitmap );
      DeleteObject( pChart->hBitmap );
      DeleteDC( pChart->hMemDC );
   }
   chc_StrFree( &pChart->szImage );
   chc_StrFree( &pChart->szFont );
   for( n = 0; n < CHC_MAXCHART; n++ )
   {
      if( s_charts[ n ] == pChart )
         s_charts[ n ] = NULL;
   }
   hb_xfree( pChart );
}

/* ---------------------------------------------------------------- control window */

static LRESULT CALLBACK chc_WndProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam )
{
   CHC_CHART * pChart = ( CHC_CHART * ) GetWindowLongPtrW( hWnd, GWLP_USERDATA );

   switch( uMsg )
   {
      case WM_ERASEBKGND:
         return 1;
      case WM_SIZE:
         /* image keeps its size, the library of interface can move or resize the window */
         InvalidateRect( hWnd, NULL, FALSE );
         return 0;
      case WM_PAINT:
      {
         PAINTSTRUCT ps;
         HDC hDC = BeginPaint( hWnd, &ps );
         if( pChart && pChart->hMemDC )
            BitBlt( hDC, 0, 0, pChart->bmpW, pChart->bmpH, pChart->hMemDC, 0, 0, SRCCOPY );
         else
         {
            RECT rc;
            GetClientRect( hWnd, &rc );
            FillRect( hDC, &rc, GetSysColorBrush( COLOR_BTNFACE ) );
         }
         EndPaint( hWnd, &ps );
         return 0;
      }
   }
   return DefWindowProcW( hWnd, uMsg, wParam, lParam );
}

static HB_BOOL chc_RegisterClass( void )
{
   WNDCLASSW wc;

   if( s_lClassOk )
      return HB_TRUE;
   memset( &wc, 0, sizeof( wc ) );
   wc.style         = CS_HREDRAW | CS_VREDRAW;
   wc.lpfnWndProc   = chc_WndProc;
   wc.hInstance     = GetModuleHandleW( NULL );
   wc.hCursor       = LoadCursor( NULL, IDC_ARROW );
   wc.lpszClassName = CHC_CLASSNAME;
   if( RegisterClassW( &wc ) || GetLastError() == ERROR_CLASS_ALREADY_EXISTS )
      s_lClassOk = HB_TRUE;
   return s_lClassOk;
}

/* ---------------------------------------------------------------- layout helpers */

typedef struct
{
   REAL x, y, w, h;
} CHC_BOX;

static int chc_ResolveSize( int iPos, int iSize, int iTotal )
{
   /* zero or negative size = distance from the right/bottom border */
   if( iSize <= 0 )
      iSize = iTotal - iPos + iSize;
   return iSize < 1 ? 1 : iSize;
}

static HB_BOOL chc_IsGridless( CHC_REGION * pRegion )
{
   int n;

   for( n = 0; n < pRegion->nSeries; n++ )
   {
      if( pRegion->series[ n ].iKind == CHC_SER_GRIDLESS )
         return HB_TRUE;
   }
   return HB_FALSE;
}

static ARGB chc_SeriesColor( CHC_REGION * pRegion, int iSeries )
{
   CHC_SERIES * pSeries = &pRegion->series[ iSeries ];

   return chc_Color( pSeries->color, CHC_PALETTE( iSeries ) );
}

static ARGB chc_PointColor( CHC_REGION * pRegion, int iSeries, int iPoint )
{
   CHC_SERIES * pSeries = &pRegion->series[ iSeries ];

   if( pSeries->pColors && iPoint < pSeries->nColors && pSeries->pColors[ iPoint ] != RMC_COLOR_DEFAULT )
      return chc_Color( pSeries->pColors[ iPoint ], CHC_PALETTE( iPoint ) );
   if( pSeries->iKind == CHC_SER_GRIDLESS )
      return CHC_PALETTE( iPoint );
   return chc_SeriesColor( pRegion, iSeries );
}

/* legend color for item n */
static ARGB chc_LegendColor( CHC_REGION * pRegion, int iItem )
{
   int n, nBar = 0;

   for( n = 0; n < pRegion->nSeries; n++ )
   {
      if( pRegion->series[ n ].iKind == CHC_SER_GRIDLESS )
         return chc_PointColor( pRegion, n, iItem );
   }
   for( n = 0; n < pRegion->nSeries; n++ )
   {
      if( ! pRegion->series[ n ].lHide )
         nBar++;
   }
   /* only one single bar series, legend by bar */
   if( nBar == 1 && pRegion->series[ 0 ].iKind == CHC_SER_BAR && pRegion->series[ 0 ].pColors )
      return chc_PointColor( pRegion, 0, iItem );
   if( iItem < pRegion->nSeries )
      return chc_SeriesColor( pRegion, iItem );
   return CHC_PALETTE( iItem );
}

/* ---------------------------------------------------------------- legend */

static void chc_LegendMeasure( CHC_DC * dc, CHC_REGION * pRegion, HB_BOOL lHorizontal, REAL fMaxW, REAL * pW, REAL * pH )
{
   CHC_LEGEND * pLegend = &pRegion->legend;
   int nItems = chc_ListCount( pLegend->szText ), n;
   char szItem[ 256 ];
   REAL tw, th, fRowW = 0, fW = 0, fH = 0, fSwatch;

   *pW = 0;
   *pH = 0;
   if( nItems == 0 )
      return;
   chc_TextSize( dc, "Ag", pLegend->iFontSize, pLegend->lBold, &tw, &th );
   fSwatch = th * 0.75f;
   for( n = 0; n < nItems; n++ )
   {
      REAL fItem;
      chc_ListItem( pLegend->szText, n, szItem, sizeof( szItem ) );
      chc_TextSize( dc, szItem, pLegend->iFontSize, pLegend->lBold, &tw, &th );
      fItem = fSwatch + 4 + tw + 12;
      if( lHorizontal )
      {
         if( fRowW + fItem > fMaxW && fRowW > 0 )
         {
            fW = HB_MAX( fW, fRowW );
            fH += th + 2;
            fRowW = 0;
         }
         fRowW += fItem;
      }
      else
      {
         fW = HB_MAX( fW, fItem );
         fH += th + 2;
      }
   }
   if( lHorizontal )
   {
      fW = HB_MAX( fW, fRowW );
      fH += th + 2;
   }
   *pW = fW + 8;
   *pH = fH + 6;
}

static void chc_LegendDraw( CHC_DC * dc, CHC_REGION * pRegion, HB_BOOL lHorizontal, REAL x, REAL y, REAL w, REAL h )
{
   CHC_LEGEND * pLegend = &pRegion->legend;
   int nItems = chc_ListCount( pLegend->szText ), n;
   int iStyle = pLegend->iStyle;
   char szItem[ 256 ];
   REAL tw, th, fSwatch, cx, cy;
   ARGB bg = chc_Color( pLegend->bgColor, 0xFFFFFFFF );
   ARGB fg = chc_Color( pLegend->textColor, 0xFF000000 );

   if( nItems == 0 )
      return;
   if( iStyle < RMC_LEGENDNORECT || iStyle > RMC_LEGENDROUNDRECTSHADOW )
      iStyle = RMC_LEGENDNORECT;

   if( iStyle == RMC_LEGENDRECTSHADOW )
      chc_FillRect( dc, 0x50000000, x + 3, y + 3, w, h );
   if( iStyle == RMC_LEGENDROUNDRECT || iStyle == RMC_LEGENDROUNDRECTSHADOW )
   {
      GpPath * path;
      GpBrush * brush;
      GpPen * pen;
      if( iStyle == RMC_LEGENDROUNDRECTSHADOW )
      {
         path  = chc_RoundRectPath( x + 3, y + 3, w, h, 6 );
         brush = chc_Solid( 0x50000000 );
         pGdipFillPath( dc->g, brush, path );
         pGdipDeleteBrush( brush );
         pGdipDeletePath( path );
      }
      path = chc_RoundRectPath( x, y, w, h, 6 );
      if( ! chc_IsTransparent( bg ) )
      {
         brush = chc_Solid( bg );
         pGdipFillPath( dc->g, brush, path );
         pGdipDeleteBrush( brush );
      }
      pen = chc_Pen( 0xFF808080, 1, RMC_LINESTYLESOLID );
      pGdipDrawPath( dc->g, pen, path );
      pGdipDeletePen( pen );
      pGdipDeletePath( path );
   }
   else if( iStyle != RMC_LEGENDNORECT )
   {
      chc_FillRect( dc, bg, x, y, w, h );
      chc_DrawRect( dc, 0xFF808080, x, y, w, h );
   }

   chc_TextSize( dc, "Ag", pLegend->iFontSize, pLegend->lBold, &tw, &th );
   fSwatch = th * 0.75f;
   cx = x + 4;
   cy = y + 3;
   for( n = 0; n < nItems; n++ )
   {
      REAL fItem;
      ARGB color = chc_LegendColor( pRegion, n );
      chc_ListItem( pLegend->szText, n, szItem, sizeof( szItem ) );
      chc_TextSize( dc, szItem, pLegend->iFontSize, pLegend->lBold, &tw, &th );
      fItem = fSwatch + 4 + tw + 12;
      if( lHorizontal && cx + fItem > x + w && cx > x + 4 )
      {
         cx = x + 4;
         cy += th + 2;
      }
      chc_FillRect( dc, color, cx, cy + ( th - fSwatch ) / 2, fSwatch, fSwatch );
      chc_DrawRect( dc, chc_Dark( color, 0.3 ), cx, cy + ( th - fSwatch ) / 2, fSwatch, fSwatch );
      chc_TextRect( dc, szItem, pLegend->iFontSize, pLegend->lBold, fg, cx + fSwatch + 4, cy, tw + 2, th, GP_ALIGNNEAR, GP_ALIGNCENTER );
      if( lHorizontal )
         cx += fItem;
      else
         cy += th + 2;
   }
}

/* legend floating inside the plot area */
static void chc_LegendFloat( CHC_DC * dc, CHC_REGION * pRegion, CHC_BOX * pPlot )
{
   int  iAlign = pRegion->legend.iAlign;
   REAL w, h, x, y;
   HB_BOOL lHorizontal = ( iAlign == RMC_LEGEND_CUSTOM_TOP || iAlign == RMC_LEGEND_CUSTOM_BOTTOM );

   chc_LegendMeasure( dc, pRegion, lHorizontal, pPlot->w - 10, &w, &h );
   x = pPlot->x + ( pPlot->w - w ) / 2;
   y = pPlot->y + ( pPlot->h - h ) / 2;
   switch( iAlign )
   {
      case RMC_LEGEND_UL: case RMC_LEGEND_CUSTOM_UL:
         x = pPlot->x + 5; y = pPlot->y + 5; break;
      case RMC_LEGEND_UR: case RMC_LEGEND_CUSTOM_UR:
         x = pPlot->x + pPlot->w - w - 5; y = pPlot->y + 5; break;
      case RMC_LEGEND_LL: case RMC_LEGEND_CUSTOM_LL:
         x = pPlot->x + 5; y = pPlot->y + pPlot->h - h - 5; break;
      case RMC_LEGEND_LR: case RMC_LEGEND_CUSTOM_LR:
         x = pPlot->x + pPlot->w - w - 5; y = pPlot->y + pPlot->h - h - 5; break;
      case RMC_LEGEND_CUSTOM_TOP:
         y = pPlot->y + 5; break;
      case RMC_LEGEND_CUSTOM_BOTTOM:
         y = pPlot->y + pPlot->h - h - 5; break;
      case RMC_LEGEND_CUSTOM_LEFT: case RMC_LEGEND_CUSTOM_CL:
         x = pPlot->x + 5; break;
      case RMC_LEGEND_CUSTOM_RIGHT: case RMC_LEGEND_CUSTOM_CR:
         x = pPlot->x + pPlot->w - w - 5; break;
   }
   chc_LegendDraw( dc, pRegion, lHorizontal, x, y, w, h );
}

static HB_BOOL chc_LegendIsFloat( int iAlign )
{
   return ( iAlign >= RMC_LEGEND_UL && iAlign <= RMC_LEGEND_LR ) ||
          ( iAlign >= RMC_LEGEND_CUSTOM_TOP && iAlign <= RMC_LEGEND_CUSTOM_CL );
}

/* ---------------------------------------------------------------- bars */

static void chc_BarHatch( CHC_DC * dc, CHC_BOX * pBar, ARGB color, int iSeries )
{
   GpBrush * brush = NULL;
   static const int s_hatch[] = { 4, 5, 2, 3, 0, 1, 8, 9 }; /* GDI+ HatchStyle */

   pGdipCreateHatchBrush( s_hatch[ iSeries % 8 ], chc_Alpha( chc_Dark( color, 0.5 ), 140 ), 0x00FFFFFF, &brush );
   pGdipFillRectangle( dc->g, brush, pBar->x, pBar->y, pBar->w, pBar->h );
   pGdipDeleteBrush( brush );
}

static void chc_BarDraw( CHC_DC * dc, CHC_BOX * pBar, ARGB color, int iStyle, HB_BOOL lHorizontal )
{
   REAL x = pBar->x, y = pBar->y, w = pBar->w, h = pBar->h;
   ARGB light = chc_Light( color, 0.55 );
   ARGB dark  = chc_Dark( color, 0.35 );

   if( w < 0.5f || h < 0.5f )
      return;

   switch( iStyle )
   {
      case RMC_BAR_FLAT_GRADIENT1:
         chc_FillGradient( dc, light, color, x, y, w, h, lHorizontal, HB_FALSE );
         chc_DrawRect( dc, dark, x, y, w, h );
         break;

      case RMC_BAR_HOVER:
         if( lHorizontal )
            chc_FillRect( dc, 0x40000000, x + 4, y + 4, w - 4, h );
         else
            chc_FillRect( dc, 0x40000000, x + 4, y + 4, w, h - 4 );
         chc_FillGradient( dc, color, light, x, y, w, h, lHorizontal, HB_TRUE );
         chc_DrawRect( dc, dark, x, y, w, h );
         break;

      case RMC_COLUMN_FLAT:
         chc_FillRect( dc, color, x, y, w, h );
         break;

      case RMC_BAR_3D:
      case RMC_BAR_3D_GRADIENT:
      {
         CHC_POINTF pt[ 4 ];
         GpBrush * brush;
         REAL d = ( lHorizontal ? h : w ) * 0.35f;
         if( d > 14 )
            d = 14;
         /* front */
         if( iStyle == RMC_BAR_3D_GRADIENT )
            chc_FillGradient( dc, color, light, x, y, w, h, lHorizontal, HB_TRUE );
         else
            chc_FillRect( dc, color, x, y, w, h );
         /* top */
         pt[ 0 ].X = x;         pt[ 0 ].Y = y;
         pt[ 1 ].X = x + d;     pt[ 1 ].Y = y - d;
         pt[ 2 ].X = x + w + d; pt[ 2 ].Y = y - d;
         pt[ 3 ].X = x + w;     pt[ 3 ].Y = y;
         brush = chc_Solid( chc_Light( color, 0.35 ) );
         pGdipFillPolygon( dc->g, brush, pt, 4, GP_FILLALTERNATE );
         pGdipDeleteBrush( brush );
         /* right side */
         pt[ 0 ].X = x + w;     pt[ 0 ].Y = y;
         pt[ 1 ].X = x + w + d; pt[ 1 ].Y = y - d;
         pt[ 2 ].X = x + w + d; pt[ 2 ].Y = y + h - d;
         pt[ 3 ].X = x + w;     pt[ 3 ].Y = y + h;
         brush = chc_Solid( chc_Dark( color, 0.3 ) );
         pGdipFillPolygon( dc->g, brush, pt, 4, GP_FILLALTERNATE );
         pGdipDeleteBrush( brush );
         break;
      }

      case RMC_COLUMN_3D:
      case RMC_COLUMN_3D_GRADIENT:
      case RMC_COLUMN_FLUTED:
      {
         GpBrush * brush;
         REAL e = ( lHorizontal ? h : w ) * 0.3f;
         if( lHorizontal )
         {
            /* body, bottom cap, top cap */
            chc_FillGradient( dc, dark, light, x, y, w, h, HB_TRUE, HB_TRUE );
            brush = chc_Solid( dark );
            pGdipFillEllipse( dc->g, brush, x - e / 2, y, e, h );
            pGdipDeleteBrush( brush );
            brush = chc_Solid( chc_Light( color, 0.25 ) );
            pGdipFillEllipse( dc->g, brush, x + w - e / 2, y, e, h );
            pGdipDeleteBrush( brush );
         }
         else
         {
            chc_FillGradient( dc, dark, light, x, y, w, h, HB_FALSE, HB_TRUE );
            brush = chc_Solid( dark );
            pGdipFillEllipse( dc->g, brush, x, y + h - e / 2, w, e );
            pGdipDeleteBrush( brush );
            chc_FillGradient( dc, dark, light, x, y + h - e / 2, w, e / 2, HB_FALSE, HB_TRUE );
            brush = chc_Solid( chc_Light( color, 0.25 ) );
            pGdipFillEllipse( dc->g, brush, x, y - e / 2, w, e );
            pGdipDeleteBrush( brush );
         }
         if( iStyle == RMC_COLUMN_FLUTED )
         {
            int k;
            for( k = 1; k < 4; k++ )
            {
               if( lHorizontal )
                  chc_Line( dc, chc_Alpha( dark, 90 ), RMC_LINESTYLESOLID, x, y + h * k / 4, x + w, y + h * k / 4 );
               else
                  chc_Line( dc, chc_Alpha( dark, 90 ), RMC_LINESTYLESOLID, x + w * k / 4, y, x + w * k / 4, y + h );
            }
         }
         break;
      }

      case RMC_BAR_FLAT:
         chc_FillRect( dc, color, x, y, w, h );
         chc_DrawRect( dc, dark, x, y, w, h );
         break;

      default: /* RMC_BAR_FLAT_GRADIENT2 */
         chc_FillGradient( dc, color, light, x, y, w, h, lHorizontal, HB_TRUE );
         break;
   }
}

/* value label of bar or slice */
static void chc_ValueText( CHC_SERIES * pSeries, double dValue, double dTotal, int nDecimals, const char * szUnit, char * szDest, int iSize )
{
   char szValue[ 64 ], szPct[ 32 ];
   int  iVLabel = pSeries->iVLabel;
   HB_BOOL lNoZero = iVLabel > 10;

   *szDest = '\0';
   if( lNoZero )
      iVLabel -= 10;
   if( iVLabel == RMC_VLABEL_NONE || iVLabel == RMC_VLABEL_LEGENDONLY || ( lNoZero && dValue == 0 ) )
      return;
   chc_FormatValue( dValue, nDecimals, szUnit, szValue, sizeof( szValue ) );
   chc_FormatValue( dTotal != 0 ? dValue * 100 / dTotal : 0, 1, "", szPct, sizeof( szPct ) );
   switch( iVLabel )
   {
      case RMC_VLABEL_PERCENT:
         hb_snprintf( szDest, iSize, "%s%%", szPct );
         break;
      case RMC_VLABEL_TWIN:
         hb_snprintf( szDest, iSize, "%s (%s%%)", szValue, szPct );
         break;
      default:
         if( pSeries->iKind == CHC_SER_GRIDLESS )
         {
            hb_snprintf( szDest, iSize, "%s%%", szPct );
            break;
         }
         hb_strncpy( szDest, szValue, iSize - 1 );
   }
}

static int chc_Decimals( double dValue )
{
   int n;

   for( n = 0; n < 4; n++ )
   {
      if( fabs( dValue - floor( dValue + 0.5 ) ) < 1e-9 )
         break;
      dValue *= 10;
   }
   return n;
}

/* nice scale when axis has no min/max */
static void chc_AutoScale( double dLow, double dHigh, int nTicks, double * pMin, double * pMax )
{
   double dRange, dStep, dMag, dNorm;

   if( dLow > 0 )
      dLow = 0;
   if( dHigh < 0 )
      dHigh = 0;
   if( dHigh <= dLow )
      dHigh = dLow + 1;
   if( nTicks < 2 )
      nTicks = 6;
   dRange = dHigh - dLow;
   dStep  = dRange / ( nTicks - 1 );
   dMag   = pow( 10, floor( log10( dStep ) ) );
   dNorm  = dStep / dMag;
   if( dNorm <= 1 )
      dStep = dMag;
   else if( dNorm <= 2 )
      dStep = 2 * dMag;
   else if( dNorm <= 2.5 )
      dStep = 2.5 * dMag;
   else if( dNorm <= 5 )
      dStep = 5 * dMag;
   else
      dStep = 10 * dMag;
   *pMin = floor( dLow / dStep ) * dStep;
   *pMax = *pMin + dStep * ( nTicks - 1 );
   while( *pMax < dHigh )
      *pMax += dStep;
}

typedef struct
{
   CHC_BOX     grid;
   HB_BOOL     lVertical;      /* bars vertical, data axis left/right */
   double      dMin[ 2 ];
   double      dMax[ 2 ];
   int         nCat;
} CHC_GRIDINFO;

static REAL chc_ValuePos( CHC_GRIDINFO * pInfo, int iAxis, double dValue )
{
   double dRange = pInfo->dMax[ iAxis ] - pInfo->dMin[ iAxis ];
   double dRel;

   if( dRange == 0 )
      dRange = 1;
   dRel = ( dValue - pInfo->dMin[ iAxis ] ) / dRange;
   if( pInfo->lVertical )
      return pInfo->grid.y + pInfo->grid.h - ( REAL ) ( dRel * pInfo->grid.h );
   return pInfo->grid.x + ( REAL ) ( dRel * pInfo->grid.w );
}

static void chc_BarsDraw( CHC_DC * dc, CHC_REGION * pRegion, CHC_GRIDINFO * pInfo )
{
   int  nSlots = 0, iStackSlot = -1, n, i;
   int  aSlot[ CHC_MAXSERIES ];
   REAL fCat, fGroup, fSlot;
   double * pPos, * pNeg, * pTotal;

   for( n = 0; n < pRegion->nSeries; n++ )
   {
      CHC_SERIES * pSeries = &pRegion->series[ n ];
      aSlot[ n ] = -1;
      if( pSeries->iKind != CHC_SER_BAR || pSeries->lHide )
         continue;
      if( pSeries->iType == RMC_BARSTACKED || pSeries->iType == RMC_BARSTACKED100 )
      {
         if( iStackSlot < 0 )
            iStackSlot = nSlots++;
         aSlot[ n ] = iStackSlot;
      }
      else
         aSlot[ n ] = nSlots++;
   }
   if( nSlots == 0 || pInfo->nCat == 0 )
      return;

   fCat   = ( pInfo->lVertical ? pInfo->grid.w : pInfo->grid.h ) / pInfo->nCat;
   fGroup = fCat * ( nSlots == 1 ? 0.6f : 0.8f );
   fSlot  = fGroup / nSlots;

   pPos   = ( double * ) hb_xgrab( sizeof( double ) * pInfo->nCat );
   pNeg   = ( double * ) hb_xgrab( sizeof( double ) * pInfo->nCat );
   pTotal = ( double * ) hb_xgrab( sizeof( double ) * pInfo->nCat );
   for( i = 0; i < pInfo->nCat; i++ )
   {
      pPos[ i ] = pNeg[ i ] = pTotal[ i ] = 0;
      for( n = 0; n < pRegion->nSeries; n++ )
      {
         CHC_SERIES * pSeries = &pRegion->series[ n ];
         if( aSlot[ n ] == iStackSlot && iStackSlot >= 0 && i < pSeries->nData )
            pTotal[ i ] += fabs( pSeries->pData[ i ] );
      }
   }

   for( n = 0; n < pRegion->nSeries; n++ )
   {
      CHC_SERIES * pSeries = &pRegion->series[ n ];
      int  iAxis = ( pSeries->iAxis == 2 && pRegion->nDAxis > 1 ) ? 1 : 0;
      int  nDecimals = pRegion->daxis[ iAxis ].lSet ? pRegion->daxis[ iAxis ].nDecimals : 0;
      double dSum = 0;

      if( aSlot[ n ] < 0 )
         continue;
      for( i = 0; i < pSeries->nData; i++ )
         dSum += fabs( pSeries->pData[ i ] );

      for( i = 0; i < pSeries->nData && i < pInfo->nCat; i++ )
      {
         double dValue = pSeries->pData[ i ], dFrom, dTo;
         REAL   p1, p2, fStart;
         CHC_BOX bar;
         ARGB   color = chc_PointColor( pRegion, n, i );
         HB_BOOL lStack = ( aSlot[ n ] == iStackSlot );
         char   szLabel[ 96 ];

         if( lStack )
         {
            if( pSeries->iType == RMC_BARSTACKED100 )
               dValue = pTotal[ i ] != 0 ? dValue * 100 / pTotal[ i ] : 0;
            if( dValue >= 0 )
            {
               dFrom = pPos[ i ];
               dTo   = pPos[ i ] += dValue;
            }
            else
            {
               dFrom = pNeg[ i ];
               dTo   = pNeg[ i ] += dValue;
            }
         }
         else
         {
            dFrom = 0;
            if( dFrom < pInfo->dMin[ iAxis ] )
               dFrom = pInfo->dMin[ iAxis ];
            if( dFrom > pInfo->dMax[ iAxis ] )
               dFrom = pInfo->dMax[ iAxis ];
            dTo = dValue;
         }
         if( dTo > pInfo->dMax[ iAxis ] )
            dTo = pInfo->dMax[ iAxis ];
         if( dTo < pInfo->dMin[ iAxis ] )
            dTo = pInfo->dMin[ iAxis ];
         p1 = ( REAL ) floor( chc_ValuePos( pInfo, iAxis, dFrom ) + 0.5 );
         p2 = ( REAL ) floor( chc_ValuePos( pInfo, iAxis, dTo ) + 0.5 );
         fStart = ( REAL ) floor( i * fCat + ( fCat - fGroup ) / 2 + aSlot[ n ] * fSlot + 0.5 );
         if( pInfo->lVertical )
         {
            bar.x = pInfo->grid.x + fStart + ( nSlots > 1 ? 1 : 0 );
            bar.w = fSlot - ( nSlots > 1 ? 2 : 0 );
            bar.y = HB_MIN( p1, p2 );
            bar.h = ( REAL ) fabs( p2 - p1 );
         }
         else
         {
            bar.y = pInfo->grid.y + fStart + ( nSlots > 1 ? 1 : 0 );
            bar.h = fSlot - ( nSlots > 1 ? 2 : 0 );
            bar.x = HB_MIN( p1, p2 );
            bar.w = ( REAL ) fabs( p2 - p1 );
         }
         if( pSeries->lLucent )
            color = chc_Alpha( color, 150 );
         chc_BarDraw( dc, &bar, color, pSeries->iStyle, ! pInfo->lVertical );
         if( pSeries->iHatch == RMC_HATCHBRUSH_ON )
            chc_BarHatch( dc, &bar, color, n );

         chc_ValueText( pSeries, pSeries->pData[ i ], dSum, nDecimals, "", szLabel, sizeof( szLabel ) );
         if( *szLabel )
         {
            REAL tw, th;
            chc_TextSize( dc, szLabel, 7, HB_FALSE, &tw, &th );
            if( lStack )
               chc_TextAngle( dc, szLabel, 7, HB_FALSE, chc_Contrast( color ), bar.x + bar.w / 2, bar.y + bar.h / 2, 0 );
            else if( pInfo->lVertical )
               chc_TextAngle( dc, szLabel, 7, HB_FALSE, 0xFF000000, bar.x + bar.w / 2, ( dValue >= 0 ? bar.y - th / 2 - 1 : bar.y + bar.h + th / 2 + 1 ) - ( pSeries->iStyle == RMC_BAR_3D || pSeries->iStyle == RMC_BAR_3D_GRADIENT ? HB_MIN( bar.w * 0.35f, 14 ) : 0 ), 0 );
            else
               chc_TextAngle( dc, szLabel, 7, HB_FALSE, 0xFF000000, ( dValue >= 0 ? bar.x + bar.w + tw / 2 + 2 : bar.x - tw / 2 - 2 ), bar.y + bar.h / 2, 0 );
         }
      }
   }
   hb_xfree( pPos );
   hb_xfree( pNeg );
   hb_xfree( pTotal );
}

/* ---------------------------------------------------------------- grid and axis */

static void chc_DataRange( CHC_REGION * pRegion, int iAxis, double * pLow, double * pHigh, HB_BOOL * pl100 )
{
   int n, i, nMax = 0;
   double * pPos, * pNeg;

   *pLow = 0;
   *pHigh = 0;
   *pl100 = HB_FALSE;
   for( n = 0; n < pRegion->nSeries; n++ )
      nMax = HB_MAX( nMax, pRegion->series[ n ].nData );
   if( nMax == 0 )
      return;
   pPos = ( double * ) hb_xgrab( sizeof( double ) * nMax );
   pNeg = ( double * ) hb_xgrab( sizeof( double ) * nMax );
   for( i = 0; i < nMax; i++ )
      pPos[ i ] = pNeg[ i ] = 0;
   for( n = 0; n < pRegion->nSeries; n++ )
   {
      CHC_SERIES * pSeries = &pRegion->series[ n ];
      int iSerAxis = ( pSeries->iAxis == 2 && pRegion->nDAxis > 1 ) ? 1 : 0;
      if( pSeries->iKind == CHC_SER_GRIDLESS || pSeries->lHide || iSerAxis != iAxis )
         continue;
      if( pSeries->iType == RMC_BARSTACKED100 && pSeries->iKind == CHC_SER_BAR )
         *pl100 = HB_TRUE;
      for( i = 0; i < pSeries->nData; i++ )
      {
         double d = pSeries->pData[ i ];
         if( pSeries->iKind == CHC_SER_BAR && pSeries->iType == RMC_BARSTACKED )
         {
            if( d >= 0 )
               pPos[ i ] += d;
            else
               pNeg[ i ] += d;
            d = pPos[ i ];
            *pHigh = HB_MAX( *pHigh, pPos[ i ] );
            *pLow  = HB_MIN( *pLow, pNeg[ i ] );
         }
         else
         {
            *pHigh = HB_MAX( *pHigh, d );
            *pLow  = HB_MIN( *pLow, d );
         }
      }
   }
   hb_xfree( pPos );
   hb_xfree( pNeg );
}

static void chc_AxisLabel( CHC_DAXIS * pAxis, double dMin, double dMax, int iTick, char * szDest, int iSize )
{
   int nTicks = pAxis->nTicks < 2 ? 2 : pAxis->nTicks;

   if( pAxis->szLabels && *pAxis->szLabels )
   {
      chc_ListItem( pAxis->szLabels, iTick, szDest, iSize );
      return;
   }
   chc_FormatValue( dMin + ( dMax - dMin ) * iTick / ( nTicks - 1 ), pAxis->nDecimals, pAxis->szUnit, szDest, iSize );
}

static REAL chc_LabelAngle( int iTextAlign )
{
   if( iTextAlign == RMC_TEXTDOWNWARD )
      return 90;
   if( iTextAlign == RMC_TEXTUPWARD )
      return -90;
   return 0;
}

static void chc_GridDraw( CHC_DC * dc, CHC_REGION * pRegion, CHC_BOX * pArea )
{
   CHC_GRIDINFO info;
   CHC_DAXIS    defAxis, * pDA[ 2 ];
   CHC_LAXIS *  pLA = &pRegion->laxis;
   CHC_GRID *   pGrid = &pRegion->grid;
   REAL fLeft = 4, fRight = 4, fTop = 4, fBottom = 4, tw, th, fMaxW, fMaxH;
   int  n, i, nTicks, nAxis, iBicolor;
   char szText[ 256 ];
   int  iFS;
   HB_BOOL lBold;

   memset( &info, 0, sizeof( info ) );
   memset( &defAxis, 0, sizeof( defAxis ) );

   /* data axis, default when not informed */
   nAxis = pRegion->nDAxis;
   if( nAxis == 0 )
   {
      HB_BOOL lHorizontal = HB_FALSE;
      for( n = 0; n < pRegion->nSeries; n++ )
         lHorizontal = lHorizontal || pRegion->series[ n ].lHorizontal;
      defAxis.iAlign = lHorizontal ? RMC_DATAAXISBOTTOM : RMC_DATAAXISLEFT;
      defAxis.nTicks = 6;
      defAxis.iLineStyle = RMC_LINESTYLENONE;
      defAxis.textColor = RMC_COLOR_TRANSPARENT;
      pDA[ 0 ] = pDA[ 1 ] = &defAxis;
      nAxis = 1;
   }
   else
   {
      pDA[ 0 ] = &pRegion->daxis[ 0 ];
      pDA[ 1 ] = &pRegion->daxis[ nAxis > 1 ? 1 : 0 ];
   }
   info.lVertical = ( pDA[ 0 ]->iAlign == RMC_DATAAXISLEFT || pDA[ 0 ]->iAlign == RMC_DATAAXISRIGHT );

   /* range */
   for( n = 0; n < nAxis; n++ )
   {
      double dLow, dHigh;
      HB_BOOL l100;
      chc_DataRange( pRegion, n, &dLow, &dHigh, &l100 );
      if( pDA[ n ]->dMax > pDA[ n ]->dMin )
      {
         info.dMin[ n ] = pDA[ n ]->dMin;
         info.dMax[ n ] = pDA[ n ]->dMax;
      }
      else if( l100 )
      {
         info.dMin[ n ] = 0;
         info.dMax[ n ] = 100;
      }
      else
         chc_AutoScale( dLow, dHigh, pDA[ n ]->nTicks, &info.dMin[ n ], &info.dMax[ n ] );
   }
   if( nAxis == 1 )
   {
      info.dMin[ 1 ] = info.dMin[ 0 ];
      info.dMax[ 1 ] = info.dMax[ 0 ];
   }

   /* categories */
   info.nCat = pLA->lSet ? pLA->nCount : 0;
   for( n = 0; n < pRegion->nSeries; n++ )
   {
      if( pRegion->series[ n ].iKind != CHC_SER_GRIDLESS )
         info.nCat = HB_MAX( info.nCat, pRegion->series[ n ].nData );
   }
   if( info.nCat == 0 && pLA->lSet )
      info.nCat = chc_ListCount( pLA->szLabels );

   /* margins for data axis labels */
   for( n = 0; n < nAxis; n++ )
   {
      CHC_DAXIS * pAxis = pDA[ n ];
      nTicks = pAxis->nTicks < 2 ? 2 : pAxis->nTicks;
      fMaxW = 0;
      fMaxH = 0;
      if( ! chc_IsTransparent( chc_Color( pAxis->textColor, 0xFF000000 ) ) )
      {
         for( i = 0; i < nTicks; i++ )
         {
            chc_AxisLabel( pAxis, info.dMin[ n ], info.dMax[ n ], i, szText, sizeof( szText ) );
            chc_TextSize( dc, szText, pAxis->iFontSize, HB_FALSE, &tw, &th );
            fMaxW = HB_MAX( fMaxW, tw );
            fMaxH = HB_MAX( fMaxH, th );
         }
      }
      iFS = pAxis->iFontSize + 1;
      lBold = HB_FALSE;
      chc_TextFormat( pAxis->szText, szText, sizeof( szText ), &iFS, &lBold );
      tw = th = 0;
      if( *szText )
         chc_TextSize( dc, szText, iFS, lBold, &tw, &th );
      switch( pAxis->iAlign )
      {
         case RMC_DATAAXISLEFT:   fLeft   = HB_MAX( fLeft, fMaxW + 6 + ( th > 0 ? th + 4 : 0 ) ); fTop = HB_MAX( fTop, fMaxH / 2 + 2 ); fBottom = HB_MAX( fBottom, fMaxH / 2 + 2 ); break;
         case RMC_DATAAXISRIGHT:  fRight  = HB_MAX( fRight, fMaxW + 6 + ( th > 0 ? th + 4 : 0 ) ); fTop = HB_MAX( fTop, fMaxH / 2 + 2 ); fBottom = HB_MAX( fBottom, fMaxH / 2 + 2 ); break;
         case RMC_DATAAXISTOP:    fTop    = HB_MAX( fTop, fMaxH + 4 + ( th > 0 ? th + 2 : 0 ) ); fLeft = HB_MAX( fLeft, fMaxW / 2 + 2 ); fRight = HB_MAX( fRight, fMaxW / 2 + 2 ); break;
         default:                 fBottom = HB_MAX( fBottom, fMaxH + 4 + ( th > 0 ? th + 2 : 0 ) ); fLeft = HB_MAX( fLeft, fMaxW / 2 + 2 ); fRight = HB_MAX( fRight, fMaxW / 2 + 2 ); break;
      }
   }

   /* margins for label axis */
   if( pLA->lSet )
   {
      REAL fAngle = chc_LabelAngle( pLA->iTextAlign );
      fMaxW = 0;
      fMaxH = 0;
      for( i = 0; i < info.nCat; i++ )
      {
         chc_ListItem( pLA->szLabels, i, szText, sizeof( szText ) );
         chc_TextSize( dc, szText, pLA->iFontSize, HB_FALSE, &tw, &th );
         if( fAngle != 0 )
         {
            REAL t = tw;
            tw = th;
            th = t;
         }
         fMaxW = HB_MAX( fMaxW, tw );
         fMaxH = HB_MAX( fMaxH, th );
      }
      iFS = pLA->iFontSize + 1;
      lBold = HB_FALSE;
      chc_TextFormat( pLA->szText, szText, sizeof( szText ), &iFS, &lBold );
      tw = th = 0;
      if( *szText )
         chc_TextSize( dc, szText, iFS, lBold, &tw, &th );
      switch( pLA->iAlign )
      {
         case RMC_LABELAXISLEFT:  fLeft   = HB_MAX( fLeft, fMaxW + 6 + ( th > 0 ? th + 4 : 0 ) ); break;
         case RMC_LABELAXISRIGHT: fRight  = HB_MAX( fRight, fMaxW + 6 + ( th > 0 ? th + 4 : 0 ) ); break;
         case RMC_LABELAXISTOP:   fTop    = HB_MAX( fTop, fMaxH + 4 + ( th > 0 ? th + 2 : 0 ) ); break;
         default:                 fBottom = HB_MAX( fBottom, fMaxH + 4 + ( th > 0 ? th + 2 : 0 ) ); break;
      }
   }

   /* grid area, fixed or auto */
   if( pGrid->iWidth > 0 && pGrid->iHeight > 0 )
   {
      info.grid.x = ( REAL ) ( pRegion->x + pGrid->iLeft );
      info.grid.y = ( REAL ) ( pRegion->y + pGrid->iTop );
      info.grid.w = ( REAL ) pGrid->iWidth;
      info.grid.h = ( REAL ) pGrid->iHeight;
   }
   else
   {
      /* depth of 3D bars */
      for( n = 0; n < pRegion->nSeries; n++ )
      {
         int iStyle = pRegion->series[ n ].iStyle;
         if( pRegion->series[ n ].iKind == CHC_SER_BAR && ( iStyle == RMC_BAR_3D || iStyle == RMC_BAR_3D_GRADIENT || iStyle >= RMC_COLUMN_3D ) )
         {
            fTop   = HB_MAX( fTop, 16 );
            fRight = HB_MAX( fRight, 16 );
         }
      }
      info.grid.x = pArea->x + fLeft;
      info.grid.y = pArea->y + fTop;
      info.grid.w = pArea->w - fLeft - fRight;
      info.grid.h = pArea->h - fTop - fBottom;
   }
   info.grid.x = ( REAL ) floor( info.grid.x );
   info.grid.y = ( REAL ) floor( info.grid.y );
   info.grid.w = ( REAL ) floor( info.grid.w );
   info.grid.h = ( REAL ) floor( info.grid.h );
   if( info.grid.w < 10 || info.grid.h < 10 )
      return;

   /* background */
   {
      ARGB bg = chc_Color( pGrid->bgColor, 0xFFFFFFFF );
      if( pGrid->lSet && ! chc_IsTransparent( bg ) )
      {
         if( pGrid->lGradient )
            chc_FillGradient( dc, 0xFFFFFFFF, bg, info.grid.x, info.grid.y, info.grid.w, info.grid.h, HB_TRUE, HB_FALSE );
         else
            chc_FillRect( dc, bg, info.grid.x, info.grid.y, info.grid.w, info.grid.h );
      }
      iBicolor = pGrid->lSet ? pGrid->iBicolor : RMC_BICOLOR_NONE;
      if( chc_IsTransparent( bg ) )
         bg = 0xFFC0C0C0;
      if( iBicolor == RMC_BICOLOR_LABELAXIS || iBicolor == RMC_BICOLOR_BOTH )
      {
         REAL fCat = ( info.lVertical ? info.grid.w : info.grid.h ) / ( info.nCat > 0 ? info.nCat : 1 );
         for( i = 1; i < info.nCat; i += 2 )
         {
            if( info.lVertical )
               chc_FillRect( dc, chc_Alpha( chc_Dark( bg, 0.5 ), 40 ), info.grid.x + i * fCat, info.grid.y, fCat, info.grid.h );
            else
               chc_FillRect( dc, chc_Alpha( chc_Dark( bg, 0.5 ), 40 ), info.grid.x, info.grid.y + i * fCat, info.grid.w, fCat );
         }
      }
      if( iBicolor == RMC_BICOLOR_DATAAXIS || iBicolor == RMC_BICOLOR_BOTH )
      {
         nTicks = pDA[ 0 ]->nTicks < 2 ? 2 : pDA[ 0 ]->nTicks;
         for( i = 1; i < nTicks - 1; i += 2 )
         {
            REAL f1 = ( info.lVertical ? info.grid.h : info.grid.w ) * i / ( nTicks - 1 );
            REAL f2 = ( info.lVertical ? info.grid.h : info.grid.w ) / ( nTicks - 1 );
            if( info.lVertical )
               chc_FillRect( dc, chc_Alpha( chc_Dark( bg, 0.5 ), 40 ), info.grid.x, info.grid.y + info.grid.h - f1 - f2, info.grid.w, f2 );
            else
               chc_FillRect( dc, chc_Alpha( chc_Dark( bg, 0.5 ), 40 ), info.grid.x + f1, info.grid.y, f2, info.grid.h );
         }
      }
   }

   /* label axis lines and labels */
   if( pLA->lSet && info.nCat > 0 )
   {
      REAL fCat = ( info.lVertical ? info.grid.w : info.grid.h ) / info.nCat;
      REAL fAngle = chc_LabelAngle( pLA->iTextAlign );
      ARGB lineColor = chc_Color( pLA->lineColor, 0xFF000000 );
      ARGB textColor = chc_Color( pLA->textColor, 0xFF000000 );

      for( i = 1; i < info.nCat; i++ )
      {
         if( info.lVertical )
            chc_Line( dc, lineColor, pLA->iLineStyle, info.grid.x + i * fCat, info.grid.y, info.grid.x + i * fCat, info.grid.y + info.grid.h );
         else
            chc_Line( dc, lineColor, pLA->iLineStyle, info.grid.x, info.grid.y + i * fCat, info.grid.x + info.grid.w, info.grid.y + i * fCat );
      }
      for( i = 0; i < info.nCat; i++ )
      {
         REAL cx, cy;
         chc_ListItem( pLA->szLabels, i, szText, sizeof( szText ) );
         if( *szText == '\0' )
            continue;
         chc_TextSize( dc, szText, pLA->iFontSize, HB_FALSE, &tw, &th );
         if( fAngle != 0 )
         {
            REAL t = tw;
            tw = th;
            th = t;
         }
         switch( pLA->iAlign )
         {
            case RMC_LABELAXISLEFT:
               cx = info.grid.x - 4 - tw / 2; cy = info.grid.y + i * fCat + fCat / 2; break;
            case RMC_LABELAXISRIGHT:
               cx = info.grid.x + info.grid.w + 4 + tw / 2; cy = info.grid.y + i * fCat + fCat / 2; break;
            case RMC_LABELAXISTOP:
               cx = info.grid.x + i * fCat + fCat / 2; cy = info.grid.y - 3 - th / 2; break;
            default:
               cx = info.grid.x + i * fCat + fCat / 2; cy = info.grid.y + info.grid.h + 3 + th / 2; break;
         }
         if( fAngle == 0 && pLA->iTextAlign != RMC_TEXTCENTER && ! info.lVertical )
         {
            if( pLA->iTextAlign == RMC_TEXTLEFT && pLA->iAlign == RMC_LABELAXISLEFT )
               cx = pArea->x + tw / 2 + 2;
         }
         chc_TextAngle( dc, szText, pLA->iFontSize, HB_FALSE, textColor, cx, cy, fAngle );
      }
      iFS = pLA->iFontSize + 1;
      lBold = HB_FALSE;
      chc_TextFormat( pLA->szText, szText, sizeof( szText ), &iFS, &lBold );
      if( *szText )
      {
         chc_TextSize( dc, szText, iFS, lBold, &tw, &th );
         switch( pLA->iAlign )
         {
            case RMC_LABELAXISLEFT:  chc_TextAngle( dc, szText, iFS, lBold, textColor, pArea->x + th / 2 + 1, info.grid.y + info.grid.h / 2, -90 ); break;
            case RMC_LABELAXISRIGHT: chc_TextAngle( dc, szText, iFS, lBold, textColor, pArea->x + pArea->w - th / 2 - 1, info.grid.y + info.grid.h / 2, 90 ); break;
            case RMC_LABELAXISTOP:   chc_TextAngle( dc, szText, iFS, lBold, textColor, info.grid.x + info.grid.w / 2, pArea->y + th / 2 + 1, 0 ); break;
            default:                 chc_TextAngle( dc, szText, iFS, lBold, textColor, info.grid.x + info.grid.w / 2, pArea->y + pArea->h - th / 2 - 1, 0 ); break;
         }
      }
   }

   /* data axis lines and labels */
   for( n = 0; n < nAxis; n++ )
   {
      CHC_DAXIS * pAxis = pDA[ n ];
      ARGB lineColor = chc_Color( pAxis->lineColor, 0xFF000000 );
      ARGB textColor = chc_Color( pAxis->textColor, 0xFF000000 );
      nTicks = pAxis->nTicks < 2 ? 2 : pAxis->nTicks;
      for( i = 0; i < nTicks; i++ )
      {
         REAL fPos = ( info.lVertical ? info.grid.h : info.grid.w ) * i / ( nTicks - 1 );
         if( n == 0 && i > 0 && i < nTicks - 1 )
         {
            if( info.lVertical )
               chc_Line( dc, lineColor, pAxis->iLineStyle, info.grid.x, info.grid.y + info.grid.h - fPos, info.grid.x + info.grid.w - 1, info.grid.y + info.grid.h - fPos );
            else
               chc_Line( dc, lineColor, pAxis->iLineStyle, info.grid.x + fPos, info.grid.y, info.grid.x + fPos, info.grid.y + info.grid.h - 1 );
         }
         chc_AxisLabel( pAxis, info.dMin[ n ], info.dMax[ n ], i, szText, sizeof( szText ) );
         chc_TextSize( dc, szText, pAxis->iFontSize, HB_FALSE, &tw, &th );
         switch( pAxis->iAlign )
         {
            case RMC_DATAAXISLEFT:
               chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x - 3, info.grid.y + info.grid.h - fPos, info.grid.x, info.grid.y + info.grid.h - fPos );
               chc_TextRect( dc, szText, pAxis->iFontSize, HB_FALSE, textColor, info.grid.x - 5 - tw, info.grid.y + info.grid.h - fPos - th / 2, tw, th, GP_ALIGNFAR, GP_ALIGNCENTER );
               break;
            case RMC_DATAAXISRIGHT:
               chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x + info.grid.w - 1, info.grid.y + info.grid.h - fPos, info.grid.x + info.grid.w + 2, info.grid.y + info.grid.h - fPos );
               chc_TextRect( dc, szText, pAxis->iFontSize, HB_FALSE, textColor, info.grid.x + info.grid.w + 4, info.grid.y + info.grid.h - fPos - th / 2, tw, th, GP_ALIGNNEAR, GP_ALIGNCENTER );
               break;
            case RMC_DATAAXISTOP:
               chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x + fPos, info.grid.y - 3, info.grid.x + fPos, info.grid.y );
               chc_TextAngle( dc, szText, pAxis->iFontSize, HB_FALSE, textColor, info.grid.x + fPos, info.grid.y - 4 - th / 2, 0 );
               break;
            default:
               chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x + fPos, info.grid.y + info.grid.h - 1, info.grid.x + fPos, info.grid.y + info.grid.h + 2 );
               chc_TextAngle( dc, szText, pAxis->iFontSize, HB_FALSE, textColor, info.grid.x + fPos, info.grid.y + info.grid.h + 3 + th / 2, 0 );
               break;
         }
      }
      /* axis line */
      switch( pAxis->iAlign )
      {
         case RMC_DATAAXISLEFT:  chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x, info.grid.y, info.grid.x, info.grid.y + info.grid.h - 1 ); break;
         case RMC_DATAAXISRIGHT: chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x + info.grid.w - 1, info.grid.y, info.grid.x + info.grid.w - 1, info.grid.y + info.grid.h - 1 ); break;
         case RMC_DATAAXISTOP:   chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x, info.grid.y, info.grid.x + info.grid.w - 1, info.grid.y ); break;
         default:                chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x, info.grid.y + info.grid.h - 1, info.grid.x + info.grid.w - 1, info.grid.y + info.grid.h - 1 ); break;
      }
      /* axis text */
      iFS = pAxis->iFontSize + 1;
      lBold = HB_FALSE;
      chc_TextFormat( pAxis->szText, szText, sizeof( szText ), &iFS, &lBold );
      if( *szText )
      {
         chc_TextSize( dc, szText, iFS, lBold, &tw, &th );
         switch( pAxis->iAlign )
         {
            case RMC_DATAAXISLEFT:  chc_TextAngle( dc, szText, iFS, lBold, textColor, pArea->x + th / 2 + 1, info.grid.y + info.grid.h / 2, -90 ); break;
            case RMC_DATAAXISRIGHT: chc_TextAngle( dc, szText, iFS, lBold, textColor, pArea->x + pArea->w - th / 2 - 1, info.grid.y + info.grid.h / 2, 90 ); break;
            case RMC_DATAAXISTOP:   chc_TextAngle( dc, szText, iFS, lBold, textColor, info.grid.x + info.grid.w / 2, pArea->y + th / 2 + 1, 0 ); break;
            default:                chc_TextAngle( dc, szText, iFS, lBold, textColor, info.grid.x + info.grid.w / 2, pArea->y + pArea->h - th / 2 - 1, 0 ); break;
         }
      }
   }

   /* label axis base line */
   if( pLA->lSet )
   {
      ARGB lineColor = chc_Color( pLA->lineColor, 0xFF000000 );
      switch( pLA->iAlign )
      {
         case RMC_LABELAXISLEFT:  chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x, info.grid.y, info.grid.x, info.grid.y + info.grid.h - 1 ); break;
         case RMC_LABELAXISRIGHT: chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x + info.grid.w - 1, info.grid.y, info.grid.x + info.grid.w - 1, info.grid.y + info.grid.h - 1 ); break;
         case RMC_LABELAXISTOP:   chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x, info.grid.y, info.grid.x + info.grid.w - 1, info.grid.y ); break;
         default:                 chc_Line( dc, lineColor, RMC_LINESTYLESOLID, info.grid.x, info.grid.y + info.grid.h - 1, info.grid.x + info.grid.w - 1, info.grid.y + info.grid.h - 1 ); break;
      }
   }

   chc_BarsDraw( dc, pRegion, &info );

   if( pRegion->legend.lSet && ! pRegion->legend.lHide && chc_LegendIsFloat( pRegion->legend.iAlign ) )
      chc_LegendFloat( dc, pRegion, &info.grid );
}

/* ---------------------------------------------------------------- pie and donut */

typedef struct
{
   double dStart;
   double dSweep;
   REAL   dx, dy;      /* explode offset */
   ARGB   color;
} CHC_SLICE;

static void chc_PieWall( CHC_DC * dc, CHC_SLICE * pSlice, CHC_BOX * pEll, REAL fDepth, double a1, double a2, ARGB color, HB_BOOL lGradient )
{
   GpPath * path = NULL;
   GpBrush * brush = NULL;
   REAL x = pEll->x + pSlice->dx, y = pEll->y + pSlice->dy;

   if( a2 - a1 < 0.01 )
      return;
   pGdipCreatePath( GP_FILLWINDING, &path );
   pGdipAddPathArc( path, x, y, pEll->w, pEll->h, ( REAL ) a1, ( REAL ) ( a2 - a1 ) );
   pGdipAddPathArc( path, x, y + fDepth, pEll->w, pEll->h, ( REAL ) a2, ( REAL ) ( a1 - a2 ) );
   pGdipClosePathFigure( path );
   if( lGradient )
   {
      CHC_RECTF rc;
      rc.X = x - 1; rc.Y = y; rc.Width = pEll->w + 2; rc.Height = pEll->h + fDepth;
      pGdipCreateLineBrushFromRect( &rc, chc_Dark( color, 0.45 ), chc_Light( color, 0.1 ), GP_GRADIENTHORIZONTAL, GP_WRAPTILEFLIPXY, &brush );
      pGdipSetLineSigmaBlend( brush, 0.4f, 1.0f );
   }
   else
      brush = chc_Solid( chc_Dark( color, 0.3 ) );
   pGdipFillPath( dc->g, brush, path );
   pGdipDeleteBrush( brush );
   pGdipDeletePath( path );
}

/* visible part of the wall, front side is angle 0..180 */
static void chc_PieWallFront( CHC_DC * dc, CHC_SLICE * pSlice, CHC_BOX * pEll, REAL fDepth, HB_BOOL lFront, ARGB color, HB_BOOL lGradient )
{
   double a1 = pSlice->dStart, a2 = pSlice->dStart + pSlice->dSweep, base;

   while( a1 < 0 )
   {
      a1 += 360;
      a2 += 360;
   }
   while( a1 >= 360 )
   {
      a1 -= 360;
      a2 -= 360;
   }
   for( base = lFront ? 0 : 180; base < 720; base += 360 )
   {
      double b1 = HB_MAX( a1, base ), b2 = HB_MIN( a2, base + 180 );
      if( b2 > b1 )
         chc_PieWall( dc, pSlice, pEll, fDepth, b1, b2, color, lGradient );
   }
}

static void chc_GridlessDraw( CHC_DC * dc, CHC_REGION * pRegion, CHC_SERIES * pSeries, int iSeries, CHC_BOX * pArea )
{
   CHC_SLICE * pSlices;
   CHC_BOX ell, inner;
   double dTotal = 0, dAngle, dRange = 360, dStart = -90, dMin = 0, dMax = 0;
   int    n, nData = pSeries->nData, iMin = -1, iMax = -1, iExplode = -1;
   int    iStyle = pSeries->iStyle;
   HB_BOOL l3D = ( iStyle == RMC_PIE_3D || iStyle == RMC_PIE_3D_GRADIENT || iStyle == RMC_DONUT_3D || iStyle == RMC_DONUT_3D_GRADIENT );
   HB_BOOL lDonut = ( iStyle >= RMC_DONUT_FLAT && iStyle <= RMC_DONUT_3D_GRADIENT );
   HB_BOOL lGradient = ( iStyle == RMC_PIE_GRADIENT || iStyle == RMC_PIE_3D_GRADIENT || iStyle == RMC_DONUT_GRADIENT || iStyle == RMC_DONUT_3D_GRADIENT );
   HB_BOOL lOnLabels = pRegion->legend.lSet && ! pRegion->legend.lHide && pRegion->legend.iAlign == RMC_LEGEND_ONVLABELS;
   REAL   fW, fH, fD, fTilt, fDepth, fExplode, fMarginX = 0, fMarginY = 0, cx, cy, tw, th;
   int    iAlign = pSeries->iAlign;
   char   szText[ 256 ], szValue[ 96 ];

   HB_SYMBOL_UNUSED( iSeries );

   if( nData == 0 )
      return;
   for( n = 0; n < nData; n++ )
   {
      double d = fabs( pSeries->pData[ n ] );
      dTotal += d;
      if( iMin < 0 || d < dMin )
      {
         dMin = d;
         iMin = n;
      }
      if( iMax < 0 || d > dMax )
      {
         dMax = d;
         iMax = n;
      }
   }
   if( dTotal <= 0 )
      return;
   if( pSeries->iExplode == RMC_EXPLODE_SMALLEST )
      iExplode = iMin;
   else if( pSeries->iExplode == RMC_EXPLODE_BIGGEST )
      iExplode = iMax;
   else if( pSeries->iExplode > 0 )
      iExplode = pSeries->iExplode - 1;

   switch( iAlign )
   {
      case RMC_HALF_TOP:    dStart = 180; dRange = 180; break;
      case RMC_HALF_RIGHT:  dStart = 270; dRange = 180; break;
      case RMC_HALF_BOTTOM: dStart = 0;   dRange = 180; break;
      case RMC_HALF_LEFT:   dStart = 90;  dRange = 180; break;
      default:              iAlign = RMC_FULL; break;
   }
   if( pSeries->dStartAngle != 0 && iAlign == RMC_FULL )
      dStart = pSeries->dStartAngle - 90;

   /* space for labels outside */
   chc_TextSize( dc, "Ag", 8, HB_FALSE, &tw, &th );
   if( lOnLabels )
   {
      REAL fMax = 0;
      for( n = 0; n < nData; n++ )
      {
         chc_ListItem( pRegion->legend.szText, n, szText, sizeof( szText ) );
         chc_ValueText( pSeries, pSeries->pData[ n ], dTotal, chc_Decimals( pSeries->pData[ n ] ), "", szValue, sizeof( szValue ) );
         if( *szValue )
            hb_strncat( hb_strncat( szText, " ", sizeof( szText ) - 1 ), szValue, sizeof( szText ) - 1 );
         chc_TextSize( dc, szText, 8, HB_FALSE, &tw, &th );
         fMax = HB_MAX( fMax, tw );
      }
      fMarginX = fMax + 20;
      fMarginY = th * 2 + 10;
   }
   else
   {
      fMarginX = 10;
      fMarginY = 10;
   }

   /* diameter */
   fW = pArea->w - 2 * fMarginX;
   fH = pArea->h - 2 * fMarginY;
   fTilt = l3D ? 0.55f : 1.0f;
   if( iAlign == RMC_HALF_TOP || iAlign == RMC_HALF_BOTTOM )
      fD = HB_MIN( fW, ( fH / ( fTilt / 2 + ( l3D ? 0.12f : 0 ) ) ) );
   else if( iAlign == RMC_HALF_LEFT || iAlign == RMC_HALF_RIGHT )
      fD = HB_MIN( fW * 2, fH / ( fTilt + ( l3D ? 0.12f : 0 ) ) );
   else
      fD = HB_MIN( fW, fH / ( fTilt + ( l3D ? 0.12f : 0 ) ) );
   fD *= 0.92f;
   if( fD < 10 )
      return;
   fDepth   = l3D ? HB_MIN( fD * 0.10f, 40 ) : 0;
   fExplode = fD * 0.06f;
   fD -= fExplode * 2;

   ell.w = fD;
   ell.h = fD * fTilt;
   cx = pArea->x + pArea->w / 2;
   cy = pArea->y + pArea->h / 2 - fDepth / 2;
   switch( iAlign )
   {
      case RMC_HALF_TOP:    cy = pArea->y + pArea->h / 2 + ( ell.h / 2 - fDepth ) / 2; break;
      case RMC_HALF_BOTTOM: cy = pArea->y + pArea->h / 2 - ( ell.h / 2 + fDepth ) / 2; break;
      case RMC_HALF_RIGHT:  cx = pArea->x + pArea->w / 2 - ell.w / 4; break;
      case RMC_HALF_LEFT:   cx = pArea->x + pArea->w / 2 + ell.w / 4; break;
   }
   ell.x = cx - ell.w / 2;
   ell.y = cy - ell.h / 2;
   inner.w = ell.w * 0.5f;
   inner.h = ell.h * 0.5f;
   inner.x = cx - inner.w / 2;
   inner.y = cy - inner.h / 2;

   /* slices */
   pSlices = ( CHC_SLICE * ) hb_xgrab( sizeof( CHC_SLICE ) * nData );
   dAngle = dStart;
   for( n = 0; n < nData; n++ )
   {
      double dMid;
      pSlices[ n ].dStart = dAngle;
      pSlices[ n ].dSweep = fabs( pSeries->pData[ n ] ) * dRange / dTotal;
      pSlices[ n ].color  = chc_PointColor( pRegion, ( int ) ( pSeries - pRegion->series ), n );
      if( pSeries->lLucent )
         pSlices[ n ].color = chc_Alpha( pSlices[ n ].color, 170 );
      dMid = ( dAngle + pSlices[ n ].dSweep / 2 ) * 3.14159265358979 / 180;
      pSlices[ n ].dx = n == iExplode ? ( REAL ) ( cos( dMid ) * fExplode ) : 0;
      pSlices[ n ].dy = n == iExplode ? ( REAL ) ( sin( dMid ) * fExplode * fTilt ) : 0;
      dAngle += pSlices[ n ].dSweep;
   }

   /* 3D walls, back to front */
   if( l3D )
   {
      int k, * pOrder = ( int * ) hb_xgrab( sizeof( int ) * nData );
      double * pKey = ( double * ) hb_xgrab( sizeof( double ) * nData );
      for( n = 0; n < nData; n++ )
      {
         pOrder[ n ] = n;
         pKey[ n ] = sin( ( pSlices[ n ].dStart + pSlices[ n ].dSweep / 2 ) * 3.14159265358979 / 180 );
      }
      for( n = 0; n < nData; n++ )
      {
         for( k = n + 1; k < nData; k++ )
         {
            if( pKey[ pOrder[ k ] ] < pKey[ pOrder[ n ] ] )
            {
               int t = pOrder[ n ];
               pOrder[ n ] = pOrder[ k ];
               pOrder[ k ] = t;
            }
         }
      }
      if( lDonut )
      {
         for( n = 0; n < nData; n++ )
            chc_PieWallFront( dc, &pSlices[ pOrder[ n ] ], &inner, fDepth, HB_FALSE, pSlices[ pOrder[ n ] ].color, lGradient );
      }
      for( n = 0; n < nData; n++ )
      {
         CHC_SLICE * pSlice = &pSlices[ pOrder[ n ] ];
         /* cut faces of the exploded slice */
         if( pOrder[ n ] == iExplode || iAlign != RMC_FULL )
         {
            int e;
            for( e = 0; e < 2; e++ )
            {
               double a = ( e == 0 ? pSlice->dStart : pSlice->dStart + pSlice->dSweep ) * 3.14159265358979 / 180;
               double dNormal = a + ( e == 0 ? -1.5707963267949 : 1.5707963267949 );
               CHC_POINTF pt[ 4 ];
               GpBrush * brush;
               REAL r1x = lDonut ? inner.w / 2 : 0, r1y = lDonut ? inner.h / 2 : 0;

               /* half pie: only the faces of both ends, and only faces turned to front */
               if( pOrder[ n ] != iExplode && ! ( e == 0 ? pOrder[ n ] == 0 : pOrder[ n ] == nData - 1 ) )
                  continue;
               if( sin( dNormal ) <= 0 )
                  continue;
               pt[ 0 ].X = cx + pSlice->dx + ( REAL ) cos( a ) * r1x;       pt[ 0 ].Y = cy + pSlice->dy + ( REAL ) sin( a ) * r1y;
               pt[ 1 ].X = cx + pSlice->dx + ( REAL ) cos( a ) * ell.w / 2; pt[ 1 ].Y = cy + pSlice->dy + ( REAL ) sin( a ) * ell.h / 2;
               pt[ 2 ].X = pt[ 1 ].X;                                       pt[ 2 ].Y = pt[ 1 ].Y + fDepth;
               pt[ 3 ].X = pt[ 0 ].X;                                       pt[ 3 ].Y = pt[ 0 ].Y + fDepth;
               brush = chc_Solid( chc_Dark( pSlice->color, 0.4 ) );
               pGdipFillPolygon( dc->g, brush, pt, 4, GP_FILLALTERNATE );
               pGdipDeleteBrush( brush );
            }
         }
         chc_PieWallFront( dc, pSlice, &ell, fDepth, HB_TRUE, pSlice->color, lGradient );
      }
      hb_xfree( pOrder );
      hb_xfree( pKey );
   }

   /* top */
   for( n = 0; n < nData; n++ )
   {
      CHC_SLICE * pSlice = &pSlices[ n ];
      GpPath * path = NULL;
      GpBrush * brush = NULL;
      GpPen * pen;
      REAL x = ell.x + pSlice->dx, y = ell.y + pSlice->dy;

      if( pSlice->dSweep < 0.01 )
         continue;
      pGdipCreatePath( GP_FILLALTERNATE, &path );
      if( lDonut )
      {
         pGdipAddPathArc( path, x, y, ell.w, ell.h, ( REAL ) pSlice->dStart, ( REAL ) pSlice->dSweep );
         pGdipAddPathArc( path, inner.x + pSlice->dx, inner.y + pSlice->dy, inner.w, inner.h, ( REAL ) ( pSlice->dStart + pSlice->dSweep ), ( REAL ) -pSlice->dSweep );
         pGdipClosePathFigure( path );
      }
      else
         pGdipAddPathPie( path, x, y, ell.w, ell.h, ( REAL ) pSlice->dStart, ( REAL ) pSlice->dSweep );
      if( lGradient )
      {
         GpPath * ellPath = NULL;
         CHC_POINTF center;
         ARGB surround = pSlice->color;
         INT  nCount = 1;
         pGdipCreatePath( GP_FILLALTERNATE, &ellPath );
         pGdipAddPathEllipse( ellPath, x, y, ell.w, ell.h );
         pGdipCreatePathGradientFromPath( ellPath, &brush );
         pGdipSetPathGradientCenterColor( brush, chc_Light( pSlice->color, 0.6 ) );
         pGdipSetPathGradientSurroundColorsWithCount( brush, &surround, &nCount );
         center.X = x + ell.w * 0.4f;
         center.Y = y + ell.h * 0.35f;
         pGdipSetPathGradientCenterPoint( brush, &center );
         pGdipDeletePath( ellPath );
      }
      else
         brush = chc_Solid( pSlice->color );
      pGdipFillPath( dc->g, brush, path );
      pGdipDeleteBrush( brush );
      if( pSeries->iHatch == RMC_HATCHBRUSH_ON )
      {
         static const int s_hatch[] = { 4, 5, 2, 3, 0, 1, 8, 9 };
         pGdipCreateHatchBrush( s_hatch[ n % 8 ], chc_Alpha( chc_Dark( pSlice->color, 0.5 ), 140 ), 0x00FFFFFF, &brush );
         pGdipFillPath( dc->g, brush, path );
         pGdipDeleteBrush( brush );
      }
      pen = chc_Pen( chc_Alpha( 0xFFFFFFFF, 140 ), 1, RMC_LINESTYLESOLID );
      pGdipSetPenLineJoin( pen, GP_LINEJOINROUND );
      pGdipDrawPath( dc->g, pen, path );
      pGdipDeletePen( pen );
      pGdipDeletePath( path );
   }

   /* value labels */
   for( n = 0; n < nData; n++ )
   {
      CHC_SLICE * pSlice = &pSlices[ n ];
      double dMid = ( pSlice->dStart + pSlice->dSweep / 2 ) * 3.14159265358979 / 180;
      REAL   rx = ell.w / 2, ry = ell.h / 2, px, py;

      chc_ValueText( pSeries, pSeries->pData[ n ], dTotal, chc_Decimals( pSeries->pData[ n ] ), "", szValue, sizeof( szValue ) );
      if( lOnLabels )
      {
         REAL ex, ey, lx;
         GpPen * pen;
         chc_ListItem( pRegion->legend.szText, n, szText, sizeof( szText ) );
         if( *szValue )
            hb_strncat( hb_strncat( szText, " ", sizeof( szText ) - 1 ), szValue, sizeof( szText ) - 1 );
         if( *szText == '\0' )
            continue;
         px = cx + pSlice->dx + ( REAL ) cos( dMid ) * rx;
         py = cy + pSlice->dy + ( REAL ) sin( dMid ) * ry + ( sin( dMid ) > 0 ? fDepth : 0 );
         ex = cx + pSlice->dx + ( REAL ) cos( dMid ) * ( rx + 14 );
         ey = cy + pSlice->dy + ( REAL ) sin( dMid ) * ( ry + 14 ) + ( sin( dMid ) > 0 ? fDepth : 0 );
         lx = ex + ( cos( dMid ) >= 0 ? 10 : -10 );
         pen = chc_Pen( 0xFF606060, 1, RMC_LINESTYLESOLID );
         pGdipDrawLine( dc->g, pen, px, py, ex, ey );
         pGdipDrawLine( dc->g, pen, ex, ey, lx, ey );
         pGdipDeletePen( pen );
         chc_TextSize( dc, szText, 8, HB_FALSE, &tw, &th );
         chc_TextRect( dc, szText, 8, HB_FALSE, chc_Color( pRegion->legend.textColor, 0xFF000000 ),
            cos( dMid ) >= 0 ? lx + 2 : lx - 2 - tw, ey - th / 2, tw, th, GP_ALIGNNEAR, GP_ALIGNCENTER );
      }
      else if( *szValue )
      {
         REAL fR = lDonut ? 0.75f : 0.62f;
         px = cx + pSlice->dx + ( REAL ) cos( dMid ) * rx * fR;
         py = cy + pSlice->dy + ( REAL ) sin( dMid ) * ry * fR;
         chc_TextAngle( dc, szValue, 8, HB_TRUE, chc_Contrast( pSlice->color ), px, py, 0 );
      }
   }
   hb_xfree( pSlices );
}

/* ---------------------------------------------------------------- region and chart */

static void chc_RegionDraw( CHC_DC * dc, CHC_REGION * pRegion )
{
   CHC_BOX area;
   REAL    tw, th;
   int     n;
   CHC_CHART * pChart = dc->pChart;

   area.x = ( REAL ) pRegion->x;
   area.y = ( REAL ) pRegion->y;
   area.w = ( REAL ) chc_ResolveSize( pRegion->x, pRegion->w, pChart->w );
   area.h = ( REAL ) chc_ResolveSize( pRegion->y, pRegion->h, pChart->h );

   pGdipSetClipRect( dc->g, area.x, area.y, area.w, area.h, GP_COMBINEREPLACE );
   if( pRegion->lBorder )
      chc_DrawRect( dc, 0xFF808080, area.x, area.y, area.w, area.h );
   area.x += 2; area.y += 2; area.w -= 4; area.h -= 4;

   /* footer */
   if( pRegion->szFooter && *pRegion->szFooter )
   {
      chc_TextSize( dc, pRegion->szFooter, 7, HB_FALSE, &tw, &th );
      chc_TextRect( dc, pRegion->szFooter, 7, HB_FALSE, 0xFF404040, area.x + 2, area.y + area.h - th, area.w - 4, th, GP_ALIGNFAR, GP_ALIGNCENTER );
      area.h -= th + 2;
   }

   /* caption */
   if( pRegion->caption.lSet )
   {
      CHC_CAPTION * pCap = &pRegion->caption;
      int iFS = pCap->iFontSize;
      HB_BOOL lBold = pCap->lBold;
      char szText[ 512 ];
      REAL fH;
      chc_TextFormat( pCap->szText, szText, sizeof( szText ), &iFS, &lBold );
      chc_TextSize( dc, szText, iFS, lBold, &tw, &th );
      fH = th + 6;
      chc_FillRect( dc, chc_Color( pCap->bgColor, 0x00FFFFFF ), area.x, area.y, area.w, fH );
      chc_TextRect( dc, szText, iFS, lBold, chc_Color( pCap->textColor, 0xFF000000 ), area.x, area.y, area.w, fH, GP_ALIGNCENTER, GP_ALIGNCENTER );
      area.y += fH + 2;
      area.h -= fH + 2;
   }

   /* legend outside of plot area */
   if( pRegion->legend.lSet && ! pRegion->legend.lHide )
   {
      int  iAlign = pRegion->legend.iAlign;
      REAL w, h;
      if( iAlign == RMC_LEGEND_TOP || iAlign == RMC_LEGEND_BOTTOM )
      {
         chc_LegendMeasure( dc, pRegion, HB_TRUE, area.w - 10, &w, &h );
         chc_LegendDraw( dc, pRegion, HB_TRUE, area.x + ( area.w - w ) / 2, iAlign == RMC_LEGEND_TOP ? area.y : area.y + area.h - h, w, h );
         if( iAlign == RMC_LEGEND_TOP )
            area.y += h + 2;
         area.h -= h + 2;
      }
      else if( iAlign == RMC_LEGEND_LEFT || iAlign == RMC_LEGEND_RIGHT )
      {
         chc_LegendMeasure( dc, pRegion, HB_FALSE, area.w, &w, &h );
         chc_LegendDraw( dc, pRegion, HB_FALSE, iAlign == RMC_LEGEND_LEFT ? area.x : area.x + area.w - w, area.y + ( area.h - h ) / 2, w, h );
         if( iAlign == RMC_LEGEND_LEFT )
            area.x += w + 4;
         area.w -= w + 4;
      }
   }

   if( area.w > 10 && area.h > 10 )
   {
      if( chc_IsGridless( pRegion ) )
      {
         for( n = 0; n < pRegion->nSeries; n++ )
         {
            if( pRegion->series[ n ].iKind == CHC_SER_GRIDLESS && ! pRegion->series[ n ].lHide )
            {
               chc_GridlessDraw( dc, pRegion, &pRegion->series[ n ], n, &area );
               break;
            }
         }
         if( pRegion->legend.lSet && ! pRegion->legend.lHide && chc_LegendIsFloat( pRegion->legend.iAlign ) )
            chc_LegendFloat( dc, pRegion, &area );
      }
      else if( pRegion->grid.lSet || pRegion->nDAxis > 0 || pRegion->laxis.lSet || pRegion->nSeries > 0 )
         chc_GridDraw( dc, pRegion, &area );
   }
   pGdipResetClip( dc->g );
}

static void chc_ChartBackground( CHC_DC * dc )
{
   CHC_CHART * pChart = dc->pChart;
   REAL w = ( REAL ) dc->iWidth, h = ( REAL ) dc->iHeight;
   ARGB bg = chc_Color( pChart->bgColor, 0xFFFFFFFF );

   if( chc_IsTransparent( bg ) && pChart->hWnd )
      bg = 0xFF000000 | ( ( GetSysColor( COLOR_BTNFACE ) & 0xFF ) << 16 ) | ( GetSysColor( COLOR_BTNFACE ) & 0xFF00 ) | ( ( GetSysColor( COLOR_BTNFACE ) >> 16 ) & 0xFF );
   pGdipGraphicsClear( dc->g, chc_IsTransparent( bg ) ? 0x00FFFFFF : bg );

   if( ( pChart->iStyle == RMC_CTRLSTYLEIMAGE || pChart->iStyle == RMC_CTRLSTYLEIMAGETILED ) && pChart->szImage && *pChart->szImage )
   {
      GpImage * image = NULL;
      WCHAR * wFile = chc_Wide( pChart->szImage, NULL );
      if( pGdipLoadImageFromFile( wFile, &image ) == 0 && image )
      {
         if( pChart->iStyle == RMC_CTRLSTYLEIMAGETILED )
         {
            GpBrush * brush = NULL;
            pGdipCreateTexture( image, GP_WRAPTILE, &brush );
            pGdipFillRectangle( dc->g, brush, 0, 0, w, h );
            pGdipDeleteBrush( brush );
         }
         else
            pGdipDrawImageRectI( dc->g, image, 0, 0, dc->iWidth, dc->iHeight );
         pGdipDisposeImage( image );
      }
      hb_xfree( wFile );
   }

   switch( pChart->iStyle )
   {
      case RMC_CTRLSTYLEFLATSHADOW:
         chc_FillRect( dc, 0x30000000, w - 4, 4, 4, h - 4 );
         chc_FillRect( dc, 0x30000000, 4, h - 4, w - 8, 4 );
         chc_DrawRect( dc, 0xFF808080, 0, 0, w - 4, h - 4 );
         break;
      case RMC_CTRLSTYLE3D:
         chc_Line( dc, 0xFFFFFFFF, RMC_LINESTYLESOLID, 0, 0, w - 1, 0 );
         chc_Line( dc, 0xFFFFFFFF, RMC_LINESTYLESOLID, 0, 0, 0, h - 1 );
         chc_Line( dc, 0xFFE0E0E0, RMC_LINESTYLESOLID, 1, 1, w - 2, 1 );
         chc_Line( dc, 0xFFE0E0E0, RMC_LINESTYLESOLID, 1, 1, 1, h - 2 );
         chc_Line( dc, 0xFF404040, RMC_LINESTYLESOLID, 0, h - 1, w - 1, h - 1 );
         chc_Line( dc, 0xFF404040, RMC_LINESTYLESOLID, w - 1, 0, w - 1, h - 1 );
         chc_Line( dc, 0xFF808080, RMC_LINESTYLESOLID, 1, h - 2, w - 2, h - 2 );
         chc_Line( dc, 0xFF808080, RMC_LINESTYLESOLID, w - 2, 1, w - 2, h - 2 );
         break;
      case RMC_CTRLSTYLE3DLIGHT:
         chc_Line( dc, 0xFFFFFFFF, RMC_LINESTYLESOLID, 0, 0, w - 1, 0 );
         chc_Line( dc, 0xFFFFFFFF, RMC_LINESTYLESOLID, 0, 0, 0, h - 1 );
         chc_Line( dc, 0xFFA0A0A0, RMC_LINESTYLESOLID, 0, h - 1, w - 1, h - 1 );
         chc_Line( dc, 0xFFA0A0A0, RMC_LINESTYLESOLID, w - 1, 0, w - 1, h - 1 );
         break;
   }
}

static void chc_WaterMark( CHC_DC * dc )
{
   REAL tw, th, x;
   int  iSize;

   if( s_szWaterMark == NULL || *s_szWaterMark == '\0' )
      return;
   iSize = s_wmFontSize;
   if( iSize <= 0 )
   {
      chc_TextSize( dc, s_szWaterMark, 10, HB_TRUE, &tw, &th );
      iSize = tw > 0 ? ( int ) ( 10 * dc->iWidth * 0.6 / tw ) : 10;
      if( iSize > ( int ) ( 10 * dc->iHeight * 0.5 / th ) )
         iSize = ( int ) ( 10 * dc->iHeight * 0.5 / th );
      if( iSize < 6 )
         iSize = 6;
   }
   chc_TextSize( dc, s_szWaterMark, iSize, HB_TRUE, &tw, &th );
   x = ( dc->iWidth - tw ) / 2;
   if( s_wmAlign == RMC_TEXTLEFT )
      x = 4;
   else if( s_wmAlign == RMC_TEXTRIGHT )
      x = dc->iWidth - tw - 4;
   chc_TextRect( dc, s_szWaterMark, iSize, HB_TRUE, chc_Alpha( chc_Color( s_wmColor, 0xFF000000 ), s_wmLucent ), x, ( dc->iHeight - th ) / 2, tw, th, GP_ALIGNCENTER, GP_ALIGNCENTER );
}

static void chc_Render( CHC_CHART * pChart, GpGraphics * g, int iWidth, int iHeight )
{
   CHC_DC dc;
   WCHAR * wFont;
   int n;

   memset( &dc, 0, sizeof( dc ) );
   dc.g = g;
   dc.pChart = pChart;
   dc.iWidth = iWidth;
   dc.iHeight = iHeight;
   wFont = chc_Wide( pChart->szFont && *pChart->szFont ? pChart->szFont : CHC_DEFAULTFONT, NULL );
   if( pGdipCreateFontFamilyFromName( wFont, NULL, &dc.family ) != 0 || dc.family == NULL )
   {
      hb_xfree( wFont );
      wFont = chc_Wide( CHC_DEFAULTFONT, NULL );
      if( pGdipCreateFontFamilyFromName( wFont, NULL, &dc.family ) != 0 || dc.family == NULL )
         pGdipGetGenericFontFamilySansSerif( &dc.family );
   }
   hb_xfree( wFont );

   pGdipSetSmoothingMode( g, GP_SMOOTHINGANTIALIAS );
   pGdipSetTextRenderingHint( g, GP_TEXTANTIALIASGRIDFIT );
   pGdipSetPixelOffsetMode( g, GP_PIXELOFFSETHALF );

   chc_ChartBackground( &dc );
   for( n = 0; n < pChart->nRegion; n++ )
      chc_RegionDraw( &dc, &pChart->region[ n ] );
   chc_WaterMark( &dc );

   pGdipDeleteFontFamily( dc.family );
}

/* double buffer: chart drawn on memory DC, window paints from it */
static int chc_DrawToMemory( CHC_CHART * pChart )
{
   GpGraphics * g = NULL;
   HDC hDC;

   if( pChart->hMemDC == NULL || pChart->bmpW != pChart->w || pChart->bmpH != pChart->h )
   {
      BITMAPINFO bmi;
      void * pBits = NULL;

      if( pChart->hMemDC )
      {
         SelectObject( pChart->hMemDC, pChart->hOldBitmap );
         DeleteObject( pChart->hBitmap );
         DeleteDC( pChart->hMemDC );
         pChart->hMemDC = NULL;
      }
      memset( &bmi, 0, sizeof( bmi ) );
      bmi.bmiHeader.biSize        = sizeof( BITMAPINFOHEADER );
      bmi.bmiHeader.biWidth       = pChart->w;
      bmi.bmiHeader.biHeight      = -pChart->h;
      bmi.bmiHeader.biPlanes      = 1;
      bmi.bmiHeader.biBitCount    = 32;
      bmi.bmiHeader.biCompression = BI_RGB;
      hDC = GetDC( NULL );
      pChart->hMemDC  = CreateCompatibleDC( hDC );
      pChart->hBitmap = CreateDIBSection( hDC, &bmi, DIB_RGB_COLORS, &pBits, NULL, 0 );
      ReleaseDC( NULL, hDC );
      if( pChart->hMemDC == NULL || pChart->hBitmap == NULL )
      {
         if( pChart->hMemDC )
            DeleteDC( pChart->hMemDC );
         if( pChart->hBitmap )
            DeleteObject( pChart->hBitmap );
         pChart->hMemDC = NULL;
         pChart->hBitmap = NULL;
         return RMC_ERROR_CREATEBITMAP;
      }
      pChart->hOldBitmap = ( HBITMAP ) SelectObject( pChart->hMemDC, pChart->hBitmap );
      pChart->bmpW = pChart->w;
      pChart->bmpH = pChart->h;
   }
   if( pGdipCreateFromHDC( pChart->hMemDC, &g ) != 0 || g == NULL )
      return RMC_ERROR_CREATEBITMAP;
   chc_Render( pChart, g, pChart->w, pChart->h );
   pGdipDeleteGraphics( g );

   return RMC_NO_ERROR;
}

static int chc_DrawToFile( CHC_CHART * pChart, const char * szFile, int iWidth, int iHeight )
{
   /* image encoders of GDI+ */
   static const CLSID s_clsidBmp = { 0x557CF400, 0x1A04, 0x11D3, { 0x9A, 0x73, 0x00, 0x00, 0xF8, 0x1E, 0xF3, 0x2E } };
   static const CLSID s_clsidJpg = { 0x557CF401, 0x1A04, 0x11D3, { 0x9A, 0x73, 0x00, 0x00, 0xF8, 0x1E, 0xF3, 0x2E } };
   static const CLSID s_clsidGif = { 0x557CF402, 0x1A04, 0x11D3, { 0x9A, 0x73, 0x00, 0x00, 0xF8, 0x1E, 0xF3, 0x2E } };
   static const CLSID s_clsidPng = { 0x557CF406, 0x1A04, 0x11D3, { 0x9A, 0x73, 0x00, 0x00, 0xF8, 0x1E, 0xF3, 0x2E } };
   const CLSID * pClsid = &s_clsidPng;
   const char * szExt = strrchr( szFile, '.' );
   GpImage * bitmap = NULL;
   GpGraphics * g = NULL;
   WCHAR * wFile;
   int iResult = RMC_NO_ERROR, wSave = pChart->w, hSave = pChart->h;

   if( szExt )
   {
      if( hb_stricmp( szExt, ".bmp" ) == 0 )
         pClsid = &s_clsidBmp;
      else if( hb_stricmp( szExt, ".jpg" ) == 0 || hb_stricmp( szExt, ".jpeg" ) == 0 )
         pClsid = &s_clsidJpg;
      else if( hb_stricmp( szExt, ".gif" ) == 0 )
         pClsid = &s_clsidGif;
   }
   if( iWidth <= 0 )
      iWidth = pChart->w;
   if( iHeight <= 0 )
      iHeight = pChart->h;
   if( pGdipCreateBitmapFromScan0( iWidth, iHeight, 0, GP_PIXELFORMAT32BPPARGB, NULL, &bitmap ) != 0 || bitmap == NULL )
      return RMC_ERROR_CREATEBITMAP;
   pGdipGetImageGraphicsContext( bitmap, &g );
   pChart->w = iWidth;
   pChart->h = iHeight;
   if( pClsid != &s_clsidPng )
      pGdipGraphicsClear( g, 0xFFFFFFFF );
   chc_Render( pChart, g, iWidth, iHeight );
   pChart->w = wSave;
   pChart->h = hSave;
   pGdipDeleteGraphics( g );
   wFile = chc_Wide( szFile, NULL );
   if( pGdipSaveImageToFile( bitmap, wFile, pClsid, NULL ) != 0 )
      iResult = RMC_ERROR_FILECREATE;
   hb_xfree( wFile );
   pGdipDisposeImage( bitmap );

   return iResult;
}

/* ---------------------------------------------------------------- Harbour API, same as RMC_* */

/* RMC_CreateChart( hParent, nCtrlId, nX, nY, nWidth, nHeight, nBgColor, nCtrlStyle, lExportOnly, cBgImage, cFontName, nToolTipWidth, nBitmapBgColor ) */
static void chc_CreateChart( HB_BOOL lOnDC )
{
   int iId = hb_parni( 2 ), n, iResult;
   CHC_CHART * pChart;

   iResult = chc_GdipStartup();
   if( iResult != RMC_NO_ERROR )
   {
      hb_retni( iResult );
      return;
   }
   pChart = chc_ChartGet( iId );
   if( pChart )
      chc_ChartDelete( pChart );
   for( n = 0; n < CHC_MAXCHART && s_charts[ n ]; n++ )
      ;
   if( n == CHC_MAXCHART )
   {
      hb_retni( RMC_ERROR_MAXINST );
      return;
   }
   pChart = ( CHC_CHART * ) hb_xgrabz( sizeof( CHC_CHART ) );
   s_charts[ n ] = pChart;
   pChart->iId        = iId;
   pChart->hParent    = lOnDC ? NULL : chc_parhwnd( 1 );
   pChart->hTargetDC  = lOnDC ? ( HDC ) chc_parhwnd( 1 ) : NULL;
   pChart->x          = hb_parni( 3 );
   pChart->y          = hb_parni( 4 );
   pChart->w          = hb_parni( 5 ) > 0 ? hb_parni( 5 ) : 400;
   pChart->h          = hb_parni( 6 ) > 0 ? hb_parni( 6 ) : 300;
   pChart->bgColor    = chc_parcolor( 7 );
   pChart->iStyle     = hb_parni( 8 );
   pChart->lExport    = chc_parl( 9 ) || pChart->hParent == NULL;
   pChart->szImage    = chc_StrDup( hb_parc( 10 ) );
   pChart->szFont     = chc_StrDup( hb_parc( 11 ) );
   pChart->iTipWidth  = hb_parni( 12 );
   pChart->bmpBgColor = chc_parcolor( 13 );

   if( ! pChart->lExport )
   {
      if( ! chc_RegisterClass() )
      {
         chc_ChartDelete( pChart );
         hb_retni( RMC_ERROR_CREATEWINDOW );
         return;
      }
      pChart->hWnd = CreateWindowExW( 0, CHC_CLASSNAME, L"", WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS,
         pChart->x, pChart->y, pChart->w, pChart->h, pChart->hParent, ( HMENU ) ( HB_PTRUINT ) iId, GetModuleHandleW( NULL ), NULL );
      if( pChart->hWnd == NULL )
      {
         chc_ChartDelete( pChart );
         hb_retni( RMC_ERROR_CREATEWINDOW );
         return;
      }
      SetWindowLongPtrW( pChart->hWnd, GWLP_USERDATA, ( LONG_PTR ) pChart );
   }
   hb_retni( RMC_NO_ERROR );
}

HB_FUNC( RMC_CREATECHART )
{
   chc_CreateChart( HB_FALSE );
}

/* RMC_CreateChartOnDC( hDC, nCtrlId, nX, nY, nWidth, nHeight, ... ) - same parameters, chart drawn on the DC by RMC_Draw() */
HB_FUNC( RMC_CREATECHARTONDC )
{
   chc_CreateChart( HB_TRUE );
}

/* RMC_AddRegion( nCtrlId, nLeft, nTop, nWidth, nHeight, cFooter, lShowBorder ) */
HB_FUNC( RMC_ADDREGION )
{
   CHC_CHART * pChart = chc_ChartGet( hb_parni( 1 ) );
   CHC_REGION * pRegion;

   if( pChart == NULL )
   {
      hb_retni( RMC_ERROR_CTRLID );
      return;
   }
   if( pChart->nRegion >= CHC_MAXREGION )
   {
      hb_retni( RMC_ERROR_MAXREGION );
      return;
   }
   pRegion = &pChart->region[ pChart->nRegion++ ];
   memset( pRegion, 0, sizeof( CHC_REGION ) );
   pRegion->x        = hb_parni( 2 );
   pRegion->y        = hb_parni( 3 );
   pRegion->w        = hb_parni( 4 );
   pRegion->h        = hb_parni( 5 );
   pRegion->szFooter = chc_StrDup( hb_parc( 6 ) );
   pRegion->lBorder  = chc_parl( 7 );
   hb_retni( RMC_NO_ERROR );
}

/* RMC_AddCaption( nCtrlId, nRegion, cText, nBgColor, nTextColor, nFontSize, lBold ) */
HB_FUNC( RMC_ADDCAPTION )
{
   CHC_REGION * pRegion = chc_RegionGet( hb_parni( 1 ), hb_parni( 2 ) );

   if( pRegion == NULL )
   {
      hb_retni( RMC_ERROR_WRONGREGION );
      return;
   }
   pRegion->caption.lSet      = HB_TRUE;
   chc_StrSet( &pRegion->caption.szText, hb_parc( 3 ) );
   pRegion->caption.bgColor   = chc_parcolor( 4 );
   pRegion->caption.textColor = chc_parcolor( 5 );
   pRegion->caption.iFontSize = hb_parni( 6 ) > 0 ? hb_parni( 6 ) : 9;
   pRegion->caption.lBold     = chc_parl( 7 );
   hb_retni( RMC_NO_ERROR );
}

/* RMC_AddGrid( nCtrlId, nRegion, nBgColor, lGradient, nLeft, nTop, nWidth, nHeight, nBicolor ) */
HB_FUNC( RMC_ADDGRID )
{
   CHC_REGION * pRegion = chc_RegionGet( hb_parni( 1 ), hb_parni( 2 ) );

   if( pRegion == NULL )
   {
      hb_retni( RMC_ERROR_WRONGREGION );
      return;
   }
   pRegion->grid.lSet      = HB_TRUE;
   pRegion->grid.bgColor   = chc_parcolor( 3 );
   pRegion->grid.lGradient = chc_parl( 4 );
   pRegion->grid.iLeft     = hb_parni( 5 );
   pRegion->grid.iTop      = hb_parni( 6 );
   pRegion->grid.iWidth    = hb_parni( 7 );
   pRegion->grid.iHeight   = hb_parni( 8 );
   pRegion->grid.iBicolor  = hb_parni( 9 );
   hb_retni( RMC_NO_ERROR );
}

/* RMC_AddDataAxis( nCtrlId, nRegion, nAlignment, nMinValue, nMaxValue, nTickCount, nFontSize, nTextColor, nLineColor, nLineStyle, nDecimalDigits, cUnit, cAxisText, cLabels, nLabelAlignment ) */
HB_FUNC( RMC_ADDDATAAXIS )
{
   CHC_REGION * pRegion = chc_RegionGet( hb_parni( 1 ), hb_parni( 2 ) );
   CHC_DAXIS * pAxis;

   if( pRegion == NULL )
   {
      hb_retni( RMC_ERROR_WRONGREGION );
      return;
   }
   if( pRegion->nDAxis >= 2 )
   {
      hb_retni( RMC_ERROR_AXISALIGNMENT );
      return;
   }
   pAxis = &pRegion->daxis[ pRegion->nDAxis++ ];
   pAxis->lSet        = HB_TRUE;
   pAxis->iAlign      = hb_parni( 3 ) >= RMC_DATAAXISLEFT && hb_parni( 3 ) <= RMC_DATAAXISBOTTOM ? hb_parni( 3 ) : RMC_DATAAXISLEFT;
   pAxis->dMin        = hb_parnd( 4 );
   pAxis->dMax        = hb_parnd( 5 );
   pAxis->nTicks      = hb_parni( 6 );
   pAxis->iFontSize   = hb_parni( 7 ) > 0 ? hb_parni( 7 ) : 8;
   pAxis->textColor   = chc_parcolor( 8 );
   pAxis->lineColor   = chc_parcolor( 9 );
   pAxis->iLineStyle  = hb_parni( 10 );
   pAxis->nDecimals   = hb_parni( 11 );
   chc_StrSet( &pAxis->szUnit, hb_parc( 12 ) );
   chc_StrSet( &pAxis->szText, hb_parc( 13 ) );
   chc_StrSet( &pAxis->szLabels, hb_parc( 14 ) );
   pAxis->iLabelAlign = hb_parni( 15 );
   hb_retni( RMC_NO_ERROR );
}

/* RMC_AddLabelAxis( nCtrlId, nRegion, cLabels, nStart, nCount, nAlignment, nFontSize, nTextColor, nTextAlignment, nLineColor, nLineStyle, cAxisText ) */
HB_FUNC( RMC_ADDLABELAXIS )
{
   CHC_REGION * pRegion = chc_RegionGet( hb_parni( 1 ), hb_parni( 2 ) );
   CHC_LAXIS * pAxis;

   if( pRegion == NULL )
   {
      hb_retni( RMC_ERROR_WRONGREGION );
      return;
   }
   pAxis = &pRegion->laxis;
   pAxis->lSet       = HB_TRUE;
   chc_StrSet( &pAxis->szLabels, hb_parc( 3 ) );
   pAxis->nStart     = hb_parni( 4 );
   pAxis->nCount     = hb_parni( 5 );
   pAxis->iAlign     = hb_parni( 6 ) >= RMC_LABELAXISLEFT && hb_parni( 6 ) <= RMC_LABELAXISBOTTOM ? hb_parni( 6 ) : RMC_LABELAXISBOTTOM;
   pAxis->iFontSize  = hb_parni( 7 ) > 0 ? hb_parni( 7 ) : 8;
   pAxis->textColor  = chc_parcolor( 8 );
   pAxis->iTextAlign = hb_parni( 9 );
   pAxis->lineColor  = chc_parcolor( 10 );
   pAxis->iLineStyle = hb_parni( 11 );
   chc_StrSet( &pAxis->szText, hb_parc( 12 ) );
   hb_retni( RMC_NO_ERROR );
}

/* RMC_AddLegend( nCtrlId, nRegion, cLegendText, nAlignment, nBgColor, nStyle, nTextColor, nFontSize, lBold ) */
HB_FUNC( RMC_ADDLEGEND )
{
   CHC_REGION * pRegion = chc_RegionGet( hb_parni( 1 ), hb_parni( 2 ) );
   CHC_LEGEND * pLegend;

   if( pRegion == NULL )
   {
      hb_retni( RMC_ERROR_WRONGREGION );
      return;
   }
   pLegend = &pRegion->legend;
   pLegend->lSet      = HB_TRUE;
   chc_StrSet( &pLegend->szText, hb_parc( 3 ) );
   pLegend->iAlign    = hb_parni( 4 );
   pLegend->lHide     = pLegend->iAlign == RMC_LEGEND_NONE;
   pLegend->bgColor   = chc_parcolor( 5 );
   pLegend->iStyle    = hb_parni( 6 );
   pLegend->textColor = chc_parcolor( 7 );
   pLegend->iFontSize = hb_parni( 8 ) > 0 ? hb_parni( 8 ) : 8;
   pLegend->lBold     = chc_parl( 9 );
   hb_retni( RMC_NO_ERROR );
}

static CHC_SERIES * chc_SeriesNew( int * piResult )
{
   CHC_REGION * pRegion = chc_RegionGet( hb_parni( 1 ), hb_parni( 2 ) );
   CHC_SERIES * pSeries;

   if( pRegion == NULL )
   {
      *piResult = RMC_ERROR_WRONGREGION;
      return NULL;
   }
   if( pRegion->nSeries >= CHC_MAXSERIES )
   {
      *piResult = RMC_ERROR_MAXSERIES;
      return NULL;
   }
   pSeries = &pRegion->series[ pRegion->nSeries++ ];
   memset( pSeries, 0, sizeof( CHC_SERIES ) );
   *piResult = RMC_NO_ERROR;
   return pSeries;
}

/* RMC_AddBarSeries( nCtrlId, nRegion, aData, nDataCount, nType, nStyle, lLucent, nColor, lHorizontal, nWhichDataAxis, nValueLabel, nPointsPerColumn, nHatchMode ) */
HB_FUNC( RMC_ADDBARSERIES )
{
   int iResult;
   CHC_SERIES * pSeries = chc_SeriesNew( &iResult );

   if( pSeries )
   {
      pSeries->iKind       = CHC_SER_BAR;
      pSeries->nData       = hb_parni( 4 );
      pSeries->pData       = chc_pardoubles( 3, &pSeries->nData );
      pSeries->iType       = hb_parni( 5 ) > 0 ? hb_parni( 5 ) : RMC_BARSINGLE;
      pSeries->iStyle      = hb_parni( 6 ) > 0 ? hb_parni( 6 ) : RMC_BAR_FLAT_GRADIENT2;
      pSeries->lLucent     = chc_parl( 7 );
      pSeries->color       = chc_parcolor( 8 );
      pSeries->lHorizontal = chc_parl( 9 );
      pSeries->iAxis       = hb_parni( 10 );
      pSeries->iVLabel     = hb_parni( 11 );
      pSeries->iHatch      = hb_parni( 13 );
      if( pSeries->nData == 0 )
         iResult = RMC_ERROR_NODATA;
   }
   hb_retni( iResult );
}

/* RMC_AddGridlessSeries( nCtrlId, nRegion, aData, nDataCount, aColor, nColorCount, nStyle, nAlignment, nExplodeMode, lLucent, nValueLabel, nHatchMode, nReserved ) */
HB_FUNC( RMC_ADDGRIDLESSSERIES )
{
   int iResult;
   CHC_SERIES * pSeries = chc_SeriesNew( &iResult );

   if( pSeries )
   {
      pSeries->iKind    = CHC_SER_GRIDLESS;
      pSeries->nData    = hb_parni( 4 );
      pSeries->pData    = chc_pardoubles( 3, &pSeries->nData );
      pSeries->nColors  = hb_parni( 6 );
      pSeries->pColors  = chc_parcolors( 5, &pSeries->nColors );
      pSeries->iStyle   = hb_parni( 7 ) > 0 ? hb_parni( 7 ) : RMC_PIE_FLAT;
      pSeries->iAlign   = hb_parni( 8 );
      pSeries->iExplode = hb_parni( 9 );
      pSeries->lLucent  = chc_parl( 10 );
      pSeries->iVLabel  = hb_parni( 11 );
      pSeries->iHatch   = hb_parni( 12 );
      if( pSeries->nData == 0 )
         iResult = RMC_ERROR_NODATA;
   }
   hb_retni( iResult );
}

/* not drawn yet, kept for legend and data range */
static void chc_SeriesOther( int iKind )
{
   int iResult;
   CHC_SERIES * pSeries = chc_SeriesNew( &iResult );

   if( pSeries )
   {
      pSeries->iKind = iKind;
      pSeries->lHide = HB_TRUE;
   }
   hb_retni( iResult );
}

HB_FUNC( RMC_ADDLINESERIES )       { chc_SeriesOther( CHC_SER_OTHER ); }
HB_FUNC( RMC_ADDXYSERIES )         { chc_SeriesOther( CHC_SER_OTHER ); }
HB_FUNC( RMC_ADDHIGHLOWSERIES )    { chc_SeriesOther( CHC_SER_OTHER ); }
HB_FUNC( RMC_ADDVOLUMEBARSERIES )  { chc_SeriesOther( CHC_SER_OTHER ); }

/* RMC_Draw( nCtrlId ) */
HB_FUNC( RMC_DRAW )
{
   CHC_CHART * pChart = chc_ChartGet( hb_parni( 1 ) );
   int iResult;

   if( pChart == NULL )
   {
      hb_retni( RMC_ERROR_CTRLID );
      return;
   }
   iResult = chc_DrawToMemory( pChart );
   if( iResult == RMC_NO_ERROR && pChart->hWnd )
   {
      InvalidateRect( pChart->hWnd, NULL, FALSE );
      UpdateWindow( pChart->hWnd );
   }
   if( iResult == RMC_NO_ERROR && pChart->hTargetDC )
      BitBlt( pChart->hTargetDC, pChart->x, pChart->y, pChart->w, pChart->h, pChart->hMemDC, 0, 0, SRCCOPY );
   hb_retni( iResult );
}

/* RMC_Paint( nCtrlId ), RMC_Refresh( nCtrlId ) */
HB_FUNC( RMC_PAINT )
{
   CHC_CHART * pChart = chc_ChartGet( hb_parni( 1 ) );

   if( pChart && pChart->hWnd )
   {
      InvalidateRect( pChart->hWnd, NULL, FALSE );
      UpdateWindow( pChart->hWnd );
   }
   hb_retni( pChart ? RMC_NO_ERROR : RMC_ERROR_CTRLID );
}

HB_FUNC( RMC_REFRESH )
{
   HB_FUNC_EXEC( RMC_DRAW );
}

/* RMC_Draw2File( nCtrlId, cFileName, nWidth, nHeight, nType ) - type by extension: png, jpg, bmp, gif */
HB_FUNC( RMC_DRAW2FILE )
{
   CHC_CHART * pChart = chc_ChartGet( hb_parni( 1 ) );

   if( pChart == NULL )
   {
      hb_retni( RMC_ERROR_CTRLID );
      return;
   }
   hb_retni( chc_DrawToFile( pChart, hb_parcx( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) );
}

/* RMC_Reset( nCtrlId ) - remove regions and series, keeps the window and last image */
HB_FUNC( RMC_RESET )
{
   CHC_CHART * pChart = chc_ChartGet( hb_parni( 1 ) );

   if( pChart )
      chc_ChartReset( pChart );
   hb_retni( pChart ? RMC_NO_ERROR : RMC_ERROR_CTRLID );
}

/* RMC_DeleteChart( nCtrlId ) */
HB_FUNC( RMC_DELETECHART )
{
   CHC_CHART * pChart = chc_ChartGet( hb_parni( 1 ) );

   if( pChart )
      chc_ChartDelete( pChart );
   hb_retni( pChart ? RMC_NO_ERROR : RMC_ERROR_CTRLID );
}

/* RMC_SetWatermark( cText, nColor, nLucent, nAlignment, nFontSize ) */
HB_FUNC( RMC_SETWATERMARK )
{
   chc_StrSet( &s_szWaterMark, hb_parc( 1 ) );
   s_wmColor    = chc_parcolor( 2 );
   s_wmLucent   = hb_parni( 3 ) > 0 ? hb_parni( 3 ) : 30;
   s_wmAlign    = hb_parni( 4 );
   s_wmFontSize = hb_parni( 5 );
   hb_retni( RMC_NO_ERROR );
}

/* CHC_SetNumberFormat( cDecimal, cThousand, cSuffix ) - for all charts, default "," "." "" */
HB_FUNC( CHC_SETNUMBERFORMAT )
{
   if( HB_ISCHAR( 1 ) )
      hb_strncpy( s_szDecimal, hb_parc( 1 ), sizeof( s_szDecimal ) - 1 );
   if( HB_ISCHAR( 2 ) )
      hb_strncpy( s_szThousand, hb_parc( 2 ), sizeof( s_szThousand ) - 1 );
   if( HB_ISCHAR( 3 ) )
      hb_strncpy( s_szSuffix, hb_parc( 3 ), sizeof( s_szSuffix ) - 1 );
   hb_retni( RMC_NO_ERROR );
}

/* RMC_SetSeriesColor( nCtrlId, nRegion, nSeries, nColor, nIndex ) - nIndex 0 = series color */
HB_FUNC( RMC_SETSERIESCOLOR )
{
   CHC_REGION * pRegion = chc_RegionGet( hb_parni( 1 ), hb_parni( 2 ) );
   int iSeries = hb_parni( 3 ), iIndex = hb_parni( 5 );
   CHC_SERIES * pSeries;

   if( pRegion == NULL )
   {
      hb_retni( RMC_ERROR_WRONGREGION );
      return;
   }
   if( iSeries < 1 || iSeries > pRegion->nSeries )
   {
      hb_retni( RMC_ERROR_SERIESINDEX );
      return;
   }
   pSeries = &pRegion->series[ iSeries - 1 ];
   if( iIndex <= 0 )
      pSeries->color = chc_parcolor( 4 );
   else if( iIndex <= CHC_MAXITEMS )
   {
      if( iIndex > pSeries->nColors )
      {
         int n;
         pSeries->pColors = ( ARGB * ) ( pSeries->pColors ? hb_xrealloc( pSeries->pColors, sizeof( ARGB ) * iIndex ) : hb_xgrab( sizeof( ARGB ) * iIndex ) );
         for( n = pSeries->nColors; n < iIndex; n++ )
            pSeries->pColors[ n ] = RMC_COLOR_DEFAULT;
         pSeries->nColors = iIndex;
      }
      pSeries->pColors[ iIndex - 1 ] = chc_parcolor( 4 );
   }
   hb_retni( RMC_NO_ERROR );
}

/* RMC_SetCaptionText( nCtrlId, nRegion, cText ) */
HB_FUNC( RMC_SETCAPTIONTEXT )
{
   CHC_REGION * pRegion = chc_RegionGet( hb_parni( 1 ), hb_parni( 2 ) );

   if( pRegion == NULL )
   {
      hb_retni( RMC_ERROR_WRONGREGION );
      return;
   }
   if( ! pRegion->caption.lSet )
   {
      pRegion->caption.lSet = HB_TRUE;
      pRegion->caption.iFontSize = 9;
   }
   chc_StrSet( &pRegion->caption.szText, hb_parc( 3 ) );
   hb_retni( RMC_NO_ERROR );
}

/* RMC_GetCtrlWidth( nCtrlId ), RMC_GetCtrlHeight( nCtrlId ) */
HB_FUNC( RMC_GETCTRLWIDTH )
{
   CHC_CHART * pChart = chc_ChartGet( hb_parni( 1 ) );

   hb_retni( pChart ? pChart->w : RMC_ERROR_CTRLID );
}

HB_FUNC( RMC_GETCTRLHEIGHT )
{
   CHC_CHART * pChart = chc_ChartGet( hb_parni( 1 ) );

   hb_retni( pChart ? pChart->h : RMC_ERROR_CTRLID );
}

/* RMC_GetVersion() */
HB_FUNC( RMC_GETVERSION )
{
   hb_retc( "chartclass 0.1" );
}

/* ---------------------------------------------------------------- not implemented yet */

#define CHC_TODO( name )  HB_FUNC( name ) { hb_retni( RMC_NO_ERROR ); }

CHC_TODO( RMC_ADDTOOLTIPS )
CHC_TODO( RMC_ADDXAXIS )
CHC_TODO( RMC_ADDYAXIS )
CHC_TODO( RMC_CALCAVERAGE )
CHC_TODO( RMC_CALCTREND )
CHC_TODO( RMC_COBOX )
CHC_TODO( RMC_COCIRCLE )
CHC_TODO( RMC_CODASH )
CHC_TODO( RMC_CODELETE )
CHC_TODO( RMC_COIMAGE )
CHC_TODO( RMC_COLINE )
CHC_TODO( RMC_COPOLYGON )
CHC_TODO( RMC_COSYMBOL )
CHC_TODO( RMC_COTEXT )
CHC_TODO( RMC_COVISIBLE )
CHC_TODO( RMC_CREATECHARTFROMFILE )
CHC_TODO( RMC_DRAW2CLIPBOARD )
CHC_TODO( RMC_DRAW2PRINTER )
CHC_TODO( RMC_GETCHARTSIZEFROMFILE )
CHC_TODO( RMC_GETDATA )
CHC_TODO( RMC_GETDATACOUNT )
CHC_TODO( RMC_GETDATALOCATION )
CHC_TODO( RMC_GETDATALOCATIONXY )
CHC_TODO( RMC_GETGRIDLOCATION )
CHC_TODO( RMC_GETHIGHPART )
CHC_TODO( RMC_GETIMAGESIZEFROMFILE )
CHC_TODO( RMC_GETINFO )
CHC_TODO( RMC_GETINFOXY )
CHC_TODO( RMC_GETLOWPART )
CHC_TODO( RMC_GETSERIESDATARANGE )
CHC_TODO( RMC_MAGNIFIER )
CHC_TODO( RMC_RND )
CHC_TODO( RMC_SAVEBMP )
CHC_TODO( RMC_SETCAPTIONBGCOLOR )
CHC_TODO( RMC_SETCAPTIONFONTBOLD )
CHC_TODO( RMC_SETCAPTIONFONTSIZE )
CHC_TODO( RMC_SETCAPTIONTEXTCOLOR )
CHC_TODO( RMC_SETCTRLBGCOLOR )
CHC_TODO( RMC_SETCTRLBGIMAGE )
CHC_TODO( RMC_SETCTRLFONT )
CHC_TODO( RMC_SETCTRLSIZE )
CHC_TODO( RMC_SETCTRLSTYLE )
CHC_TODO( RMC_SETCUSTOMTOOLTIPTEXT )
CHC_TODO( RMC_SETDAXALIGNMENT )
CHC_TODO( RMC_SETDAXDECIMALDIGITS )
CHC_TODO( RMC_SETDAXFONTSIZE )
CHC_TODO( RMC_SETDAXLABELALIGNMENT )
CHC_TODO( RMC_SETDAXLABELS )
CHC_TODO( RMC_SETDAXLINECOLOR )
CHC_TODO( RMC_SETDAXLINESTYLE )
CHC_TODO( RMC_SETDAXMAXVALUE )
CHC_TODO( RMC_SETDAXMINVALUE )
CHC_TODO( RMC_SETDAXTEXT )
CHC_TODO( RMC_SETDAXTEXTCOLOR )
CHC_TODO( RMC_SETDAXTICKCOUNT )
CHC_TODO( RMC_SETDAXUNIT )
CHC_TODO( RMC_SETGRIDBGCOLOR )
CHC_TODO( RMC_SETGRIDBICOLOR )
CHC_TODO( RMC_SETGRIDGRADIENT )
CHC_TODO( RMC_SETGRIDMARGIN )
CHC_TODO( RMC_SETHELPINGGRID )
CHC_TODO( RMC_SETLAXALIGNMENT )
CHC_TODO( RMC_SETLAXCOUNT )
CHC_TODO( RMC_SETLAXFONTSIZE )
CHC_TODO( RMC_SETLAXLABELALIGNMENT )
CHC_TODO( RMC_SETLAXLABELS )
CHC_TODO( RMC_SETLAXLABELSFILE )
CHC_TODO( RMC_SETLAXLABELSRANGE )
CHC_TODO( RMC_SETLAXLINECOLOR )
CHC_TODO( RMC_SETLAXLINESTYLE )
CHC_TODO( RMC_SETLAXTEXT )
CHC_TODO( RMC_SETLAXTEXTCOLOR )
CHC_TODO( RMC_SETLAXTICKCOUNT )
CHC_TODO( RMC_SETLEGENDALIGNMENT )
CHC_TODO( RMC_SETLEGENDBGCOLOR )
CHC_TODO( RMC_SETLEGENDFONTBOLD )
CHC_TODO( RMC_SETLEGENDFONTSIZE )
CHC_TODO( RMC_SETLEGENDHIDE )
CHC_TODO( RMC_SETLEGENDSTYLE )
CHC_TODO( RMC_SETLEGENDTEXT )
CHC_TODO( RMC_SETLEGENDTEXTCOLOR )
CHC_TODO( RMC_SETMOUSECLICK )
CHC_TODO( RMC_SETREGIONBORDER )
CHC_TODO( RMC_SETREGIONFOOTER )
CHC_TODO( RMC_SETREGIONMARGIN )
CHC_TODO( RMC_SETRMCFILE )
CHC_TODO( RMC_SETSERIESDATA )
CHC_TODO( RMC_SETSERIESDATAAXIS )
CHC_TODO( RMC_SETSERIESDATAFILE )
CHC_TODO( RMC_SETSERIESDATARANGE )
CHC_TODO( RMC_SETSERIESEXPLODEMODE )
CHC_TODO( RMC_SETSERIESHATCHMODE )
CHC_TODO( RMC_SETSERIESHIDE )
CHC_TODO( RMC_SETSERIESHIGHLOWCOLOR )
CHC_TODO( RMC_SETSERIESLINESTYLE )
CHC_TODO( RMC_SETSERIESLUCENT )
CHC_TODO( RMC_SETSERIESPPCOLUMN )
CHC_TODO( RMC_SETSERIESPPCOLUMNARRAY )
CHC_TODO( RMC_SETSERIESSINGLEDATA )
CHC_TODO( RMC_SETSERIESSTARTANGLE )
CHC_TODO( RMC_SETSERIESSTYLE )
CHC_TODO( RMC_SETSERIESSYMBOL )
CHC_TODO( RMC_SETSERIESVALUELABEL )
CHC_TODO( RMC_SETSERIESVERTICAL )
CHC_TODO( RMC_SETSERIESXAXIS )
CHC_TODO( RMC_SETSERIESYAXIS )
CHC_TODO( RMC_SETSINGLEBARCOLORS )
CHC_TODO( RMC_SETTOOLTIPWIDTH )
CHC_TODO( RMC_SETXAXALIGNMENT )
CHC_TODO( RMC_SETXAXDECIMALDIGITS )
CHC_TODO( RMC_SETXAXFONTSIZE )
CHC_TODO( RMC_SETXAXLABELALIGNMENT )
CHC_TODO( RMC_SETXAXLABELS )
CHC_TODO( RMC_SETXAXLINECOLOR )
CHC_TODO( RMC_SETXAXLINESTYLE )
CHC_TODO( RMC_SETXAXMAXVALUE )
CHC_TODO( RMC_SETXAXMINVALUE )
CHC_TODO( RMC_SETXAXTEXT )
CHC_TODO( RMC_SETXAXTEXTCOLOR )
CHC_TODO( RMC_SETXAXTICKCOUNT )
CHC_TODO( RMC_SETXAXUNIT )
CHC_TODO( RMC_SETYAXALIGNMENT )
CHC_TODO( RMC_SETYAXDECIMALDIGITS )
CHC_TODO( RMC_SETYAXFONTSIZE )
CHC_TODO( RMC_SETYAXLABELALIGNMENT )
CHC_TODO( RMC_SETYAXLABELS )
CHC_TODO( RMC_SETYAXLINECOLOR )
CHC_TODO( RMC_SETYAXLINESTYLE )
CHC_TODO( RMC_SETYAXMAXVALUE )
CHC_TODO( RMC_SETYAXMINVALUE )
CHC_TODO( RMC_SETYAXTEXT )
CHC_TODO( RMC_SETYAXTEXTCOLOR )
CHC_TODO( RMC_SETYAXTICKCOUNT )
CHC_TODO( RMC_SETYAXUNIT )
CHC_TODO( RMC_SHOWTOOLTIPS )
CHC_TODO( RMC_WRITERMCFILE )
CHC_TODO( RMC_ZOOM )
