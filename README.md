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
| Bar series: single, grouped, stacked, stacked 100%, horizontal, flat/gradient/3D/cylinder styles | done |
| Pie and donut: flat, gradient, 3D, full and half, explode | done |
| Watermark | done |
| `Draw2File()` to PNG, JPG, BMP, GIF | basic |
| Line and area series | next |
| Printer, clipboard | next |
| XY, high-low, volume bars, pyramid | next |
| Custom objects (`RMC_CO*`), tooltips, zoom | next |
| `.rmc` files | last |

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
- `RMC_CreateChartOnDC()` draws on a DC received, `RMC_Split*()` are simple Harbour functions.

## Tests

- `tests/testpng.prg` - charts saved to PNG files, no window. The same source compiles with
  rmchartclass, to compare.
- `tests/testwvt.prg` - charts on a GTWVT window.

```
cd tests
hbmk2 testpng.hbp
hbmk2 testwvt.hbp
```

---

RMChart is a product of its respective author. This project is independent, written from scratch, and is not affiliated with or endorsed by the RMChart author.
