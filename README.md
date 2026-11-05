# chartclass

**chartclass** — Charts for Harbour (pie, bar, line, area, donut, pyramid and more) drawn with GDI+, 32 and 64 bits. Inspired by RMChart, with a compatible `RMC_*` API.

The engine is written in C on top of the GDI+ flat API. `gdiplus.dll` is loaded at runtime
(`LoadLibrary`/`GetProcAddress`), so there are no GDI+ headers or import libraries involved, and
the same source builds with MinGW, BCC and MSVC. No external DLL is needed: `gdiplus.dll` is part
of Windows.

Programs that use the `RMC_*` API through `RMChartClass()` work by changing the library only:
`RMChartClass()` is available as an alias of `ChartClass()`, and `ze_rmchart.ch` is available as
an alias of `ze_chartclass.ch`, with the same constant names and values.

## Status

Phase 1, work in progress.

| Feature | Status |
|---|---|
| GDI+ startup/shutdown, dynamic load | done |
| Chart on a window (child control, double buffer) | done |
| Chart without window (`lExportOnly`) | done |
| Regions, caption, footer, border | done |
| Grid, bicolor, gradient, data axis (1 or 2), label axis | done |
| Legend (top, bottom, left, right, floating, on value labels) | done |
| Antialiasing, text measured with `GdipMeasureString` | done |
| Bar series: single, grouped, stacked, stacked 100%, floating, horizontal, flat/gradient/3D/cylinder styles | done |
| Pie and donut: flat, gradient, 3D, full and half, explode | done |
| Watermark | done |
| `Draw2File()` to PNG, JPG, BMP, GIF | basic |
| Line and area series: line, area, indexed, stacked, stacked 100%, spline, stair, 3D, cable, symbols | done |
| Printer (EMF+, EMF, BMP), clipboard (EMF and bitmap) | done |
| XY with X/Y axes, high-low (OHLC, candlestick), volume bars, pyramid flat and 3D | done |
| Custom objects (`RMC_CO*`), tooltips, zoom | next |
| `.rmc` files: `RMC_CreateChartFromFile()`, `RMC_GetChartSizeFromFile()`, `RMC_File2Source()` (to Harbour source) (data in the file or in a `.csv`) | basic |

Functions not implemented yet exist and return 0, so programs link and run.

## Build

```
hbmk2 chartclass.hbp
```

Creates `lib/libchartclass.a` (MinGW) or `lib/chartclass.lib` (BCC/MSVC).

## Use

Add `chartclass.hbc` to the project:

```
hbmk2 myprogram.prg chartclass.hbc
```

```harbour
#include "ze_chartclass.ch"

PROCEDURE Main()

   LOCAL oChart := ChartClass():New(), nId := oChart:GetChartId()

   oChart:CreateChart( 0, nId, 0, 0, 600, 400, RMC_COLOR_WHITE, RMC_CTRLSTYLEFLAT, .T., "", "Tahoma", 0, 0 )
   oChart:AddRegion( nId, 5, 5, -5, -5, "", .F. )
   oChart:AddCaption( nId, 1, "Sales", RMC_COLOR_STEEL_BLUE, RMC_COLOR_WHITE, 11, .T. )
   oChart:AddGrid( nId, 1, RMC_COLOR_BEIGE, .F., 0, 0, 0, 0, RMC_BICOLOR_LABELAXIS )
   oChart:AddDataAxis( nId, 1, RMC_DATAAXISLEFT, 0, 100, 11, 8, RMC_COLOR_BLACK, RMC_COLOR_BLACK, RMC_LINESTYLEDOT, 0, "", "", "", RMC_TEXTCENTER )
   oChart:AddLabelAxis( nId, 1, "Jan*Feb*Mar*Apr*May", 1, 5, RMC_LABELAXISBOTTOM, 8, RMC_COLOR_BLACK, RMC_TEXTCENTER, RMC_COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oChart:AddBarSeries( nId, 1, { 60, 70, 40, 60, 30 }, 5, RMC_BARSINGLE, RMC_BAR_FLAT_GRADIENT2, .F., RMC_COLOR_DEFAULT, .F., 1, RMC_VLABEL_DEFAULT, 1, RMC_HATCHBRUSH_OFF )
   oChart:Draw( nId )
   oChart:Draw2File( nId, "sales.png", 0, 0, 0 )
   oChart:DeleteChart( nId )

   RETURN
```

Arrays can be passed directly. Binary strings created by the old `ToDouble()`/`ToLong()`
methods are accepted too. The `RMC_*()` functions can also be called directly, without the class.

## Differences from RMChart

- Pixel-identical output is not a goal; layout and styles are similar, not equal.
- `hWnd` 0 creates a chart without window, to export only.
- Text uses the ANSI code page, or UTF-8 when the Harbour codepage is UTF-8.
- Numbers are formatted without locale: decimal "," and thousand "." by default, changed with
  `CHC_SetNumberFormat( cDecimal, cThousand, cSuffix )` or `oChart:SetNumberFormat()`.
- `CHC_ClipParent( hWnd )` or `oChart:ClipParent()` sets WS_CLIPCHILDREN on the window and its
  parents, only for a console GT (GTWVT/GTWVG), so the console repaint does not paint over the chart.
- `RMC_CreateChartOnDC()` draws on a DC received, `RMC_Split*()` are simple Harbour functions.
- Automatic scale (min = max = 0): from the data, zero is not forced, as RMChart, but the steps can be different.
- `.rmc` files: custom objects are not drawn yet, `RMC_WriteRMCFile()` is not done.
- `RMC_Draw2Printer()` with hDC 0 shows the printer dialog and prints one page. With a hDC it only
  draws, StartDoc()/StartPage() are of the caller. Position and size in mm, size 0 = printable width.

## Tests

- `tests/testpng.prg` - charts saved to PNG files, no window. The same source compiles with
  rmchartclass, to compare.
- `tests/testwvt.prg` - charts on a GTWVT window.
- `tests/rmcsamples.prg` - 23 charts of the same kind of the RMChart `.rmc` samples, with fictitious texts and data,
  created by `tests/rmc2prg.prg` (`RMC_File2Source()`). `tests/testrmcfivewin.prg` shows them in tabs,
  `tests/testrmcsamples.prg` saves them to PNG.
- `tests/testfivewin.prg` - FiveWin dialog with FOLDEREX, one chart on each of 16 tabs.
- `tests/testhwgui.prg` - hwgui dialog with TAB, one chart on a PANEL of each of 16 pages.
- `tests/testhmg3.prg`, `tests/testhmge.prg`, `tests/testoohg.prg` - HMG 3, HMG Extended and OOHG window
  with TAB, one chart on a LABEL of each of 16 pages (a page is not a window).
  All tab tests use `tests/samples.prg` (tabs A to J) and `tests/moresamples.prg` (tabs K to P),
  and the GUI library .hbc found by hbmk2 (`fivewin.hbc`, `hwgui.hbc`, `hmg3.hbc`, `hmge.hbc`, `oohg_hb.hbc`).

```
cd tests
hbmk2 testpng.hbp
hbmk2 testwvt.hbp
hbmk2 testfivewin.hbp
hbmk2 testhwgui.hbp
hbmk2 testhmg3.hbp
hbmk2 testhmge.hbp
hbmk2 testoohg.hbp
```

---

RMChart is a product of its respective author. This project is independent, written from scratch, and is not affiliated with or endorsed by the RMChart author.
