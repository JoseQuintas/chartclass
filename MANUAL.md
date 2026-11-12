# chartclass manual

How to use chartclass in a Harbour program. Function names and parameters are the same as RMChart
(`RMC_*`), so RMChart samples and documentation are useful too.

Contents

1. Build and link
2. The chart: create, regions, caption, grid, axes, legend
3. Series: bar, line/area, pie/donut/pyramid, XY, high-low, volume
4. Custom objects: text and line
5. Output: window, file, clipboard, printer
6. `.rmc` files
7. Constants and errors

---

## 1. Build and link

Build the library once:

```
hbmk2 chartclass.hbp
```

Add `chartclass.hbc` to the program:

```
hbmk2 myprogram.prg chartclass.hbc
```

Include `ze_chartclass.ch` (or `ze_rmchart.ch`, same content) for the constants.

Windows only (GDI+). `gdiplus.dll` is loaded at runtime, no other DLL is needed.
Works with console programs (GTWVT, GTWVG), FiveWin, hwgui, HMG 3, HMG Extended and OOHG:
the chart is a child window of the window handle received. See `tests/` for each library.

All functions return 0 (`RMC_NO_ERROR`) or a negative error code (chapter 7).

## 2. The chart

### Class or functions

```harbour
oChart := ChartClass():New()      // RMChartClass() is the same class
nId    := oChart:GetChartId()     // a free id
oChart:AddRegion( nId, ... )      // = RMC_AddRegion( nId, ... )
```

Each method calls the function of the same name: `oChart:Xxx( ... )` = `RMC_Xxx( ... )`.
Arrays are passed as Harbour arrays.

### Create

```
RMC_CreateChart( hParent, nCtrlId, nX, nY, nWidth, nHeight, nBgColor, nCtrlStyle,
                 lExportOnly, cBgImage, cFontName, nToolTipWidth, nBitmapBgColor )
```

- `hParent`: window handle; 0 = no window (draw to file, clipboard or printer only).
- `nCtrlStyle`: `RMC_CTRLSTYLEFLAT`, `RMC_CTRLSTYLEFLATSHADOW`, `RMC_CTRLSTYLE3D`, `RMC_CTRLSTYLE3DLIGHT`,
  `RMC_CTRLSTYLEIMAGE`, `RMC_CTRLSTYLEIMAGETILED` (these two use `cBgImage`).
- `lExportOnly`: .T. = no window, even with a `hParent`.
- `cFontName`: font for all texts, default "Tahoma".

`RMC_CreateChartOnDC( hDC, nCtrlId, ... )` has the same parameters and draws on the DC received.

### Region

A chart has 1 or more regions (up to 32), each one with its own caption, grid, axes and series.

```
RMC_AddRegion( nCtrlId, nLeft, nTop, nWidth, nHeight, cFooter, lShowBorder )
```

Position in pixels inside the chart. Negative width/height = distance from the right/bottom edge:
`5, 5, -5, -5` is the whole chart with 5 pixels of margin.

### Caption, grid, legend

```
RMC_AddCaption( nCtrlId, nRegion, cText, nBgColor, nTextColor, nFontSize, lBold )
RMC_AddGrid( nCtrlId, nRegion, nBgColor, lGradient, nLeft, nTop, nWidth, nHeight, nBicolor )
RMC_AddLegend( nCtrlId, nRegion, cLegendText, nAlignment, nBgColor, nStyle, nTextColor, nFontSize, lBold )
```

- Grid position 0, 0, 0, 0 = automatic.
- `nBicolor`: `RMC_BICOLOR_NONE`, `_DATAAXIS`, `_LABELAXIS`, `_BOTH` (alternate bands).
- Texts with several items use `*` as separator: `"Jan*Feb*Mar"`.
- Legend `nAlignment`: `RMC_LEGEND_TOP`, `_LEFT`, `_RIGHT`, `_BOTTOM`, `_UL`, `_UR`, `_LL`, `_LR`,
  `_ONVLABELS`, `_CUSTOM_*`; `nStyle`: `RMC_LEGENDNORECT`, `RMC_LEGENDRECT`, `RMC_LEGENDRECTSHADOW`,
  `RMC_LEGENDROUNDRECT`, `RMC_LEGENDROUNDRECTSHADOW`.

### Axes (bar and line charts)

```
RMC_AddDataAxis( nCtrlId, nRegion, nAlignment, nMinValue, nMaxValue, nTickCount, nFontSize,
                 nTextColor, nLineColor, nLineStyle, nDecimalDigits, cUnit, cAxisText, cLabels, nLabelAlignment )
RMC_AddLabelAxis( nCtrlId, nRegion, cLabels, nStart, nCount, nAlignment, nFontSize, nTextColor,
                  nTextAlignment, nLineColor, nLineStyle, cAxisText )
```

- Data axis: values. `nAlignment` `RMC_DATAAXISLEFT`, `_RIGHT`, `_TOP`, `_BOTTOM`. A second data axis
  is allowed (series choose with `nWhichDataAxis` 1 or 2).
- `nMinValue` = `nMaxValue` = 0: automatic scale from the data.
- `cUnit`: text added to each value, as `"%"` or `"R$ "`.
- Label axis: the names of the points, as `"Jan*Feb*Mar"`. `nAlignment` `RMC_LABELAXISBOTTOM`, etc.
- `nLineStyle`: `RMC_LINESTYLESOLID`, `_DASH`, `_DOT`, `_DASHDOT`, `_NONE`.

### Axes (XY charts)

```
RMC_AddXAxis( nCtrlId, nRegion, nAlignment, nMin, nMax, nTickCount, nFontSize, nTextColor,
              nLineColor, nLineStyle, nDecimals, cUnit, cText, cLabels, nLabelAlignment )
RMC_AddYAxis( same parameters )
```

### Number format

`CHC_SetNumberFormat( cDecimal, cThousand, cSuffix )`, for all charts. Default "," and ".".

## 3. Series

Series are drawn in the order they are added. Each series belongs to a region.

### Bar

```
RMC_AddBarSeries( nCtrlId, nRegion, aData, nDataCount, nType, nStyle, lLucent, nColor,
                  lHorizontal, nWhichDataAxis, nValueLabel, nPointsPerColumn, nHatchMode )
```

- `nType`: `RMC_BARSINGLE`, `RMC_BARGROUP`, `RMC_BARSTACKED`, `RMC_BARSTACKED100`, `RMC_FLOATINGBAR`,
  `RMC_FLOATINGBARGROUP` (floating bars: pairs start/end in `aData`).
- `nStyle`: `RMC_BAR_FLAT`, `RMC_BAR_FLAT_GRADIENT1`, `RMC_BAR_FLAT_GRADIENT2`, `RMC_BAR_HOVER`,
  `RMC_BAR_3D`, `RMC_BAR_3D_GRADIENT`, `RMC_COLUMN_FLAT`, `RMC_COLUMN_3D`, `RMC_COLUMN_FLUTED`...
- `nColor`: `RMC_COLOR_DEFAULT` = automatic color for each series.
- `nValueLabel`: value written on the bar: `RMC_VLABEL_NONE`, `_DEFAULT`, `_PERCENT`, `_ABSOLUTE`, `_TWIN`
  (`_NOZERO` variants do not write zeros).
- `RMC_SetSeriesColor( nCtrlId, nRegion, nSeries, nColor, nIndex )`: color of one bar (nIndex) or of the series (0).

### Line and area

```
RMC_AddLineSeries( nCtrlId, nRegion, aData, nDataCount, aPPC, nPPCCount, nType, nStyle,
                   nLineStyle, lLucent, nColor, nSymbol, nWhichDataAxis, nValueLabel, nHatchMode )
```

- `nType`: `RMC_LINE`, `RMC_AREA`, `RMC_LINE_INDEXED`, `RMC_AREA_INDEXED`, `RMC_AREA_STACKED`, `RMC_AREA_STACKED100`.
- `nStyle`: `RMC_LINE_FLAT`, `_FLAT_DOT`, `_FLAT_DASH`, `_CABLE`, `_CABLE_SHADOW`, `_3D`, `_SYMBOLONLY`,
  `RMC_AREA_FLAT`, `RMC_AREA_FLAT_GRADIENT_V`, `RMC_AREA_3D`...
- `nLineStyle`: `RMC_LSTYLE_LINE`, `RMC_LSTYLE_SPLINE`, `RMC_LSTYLE_STAIR`, `RMC_LSTYLE_STAIR_AREA`...
- `nSymbol`: `RMC_SYMBOL_NONE`, `_BULLET`, `_ROUND`, `_DIAMOND`, `_SQUARE`, `_STAR`... (`_SMALL` variants).
- `aPPC` (points per column): when there are more points than labels, how many points go in each label.

### Pie, donut, pyramid

```
RMC_AddGridlessSeries( nCtrlId, nRegion, aData, nDataCount, aColor, nColorCount, nStyle,
                       nAlignment, nExplodeMode, lLucent, nValueLabel, nHatchMode, nReserved )
```

- `nStyle`: `RMC_PIE_FLAT`, `RMC_PIE_GRADIENT`, `RMC_PIE_3D`, `RMC_PIE_3D_GRADIENT`, `RMC_DONUT_*`,
  `RMC_PYRAMIDE`, `RMC_PYRAMIDE3`.
- `nAlignment`: `RMC_FULL`, `RMC_HALF_TOP`, `_RIGHT`, `_BOTTOM`, `_LEFT`.
- `nExplodeMode`: `RMC_EXPLODE_NONE`, `RMC_EXPLODE_SMALLEST`, `RMC_EXPLODE_BIGGEST`, or the number of the slice.
- `aColor`: one color for each slice, or empty for automatic colors.
- No grid and no axes are needed.

### XY

```
RMC_AddXYSeries( nCtrlId, nRegion, aDataX, nDataXCount, aDataY, nDataYCount, nColor, nStyle,
                 nLineStyle, nSymbol, nWhichXAxis, nWhichYAxis, nValueLabel )
```

- Needs `RMC_AddXAxis()` and `RMC_AddYAxis()`.
- `nStyle`: `RMC_XY_LINE`, `_LINE_DOT`, `_LINE_DASH`, `RMC_XY_SYMBOL` (points only), `RMC_XY_CABLE`.

### High-low and volume

```
RMC_AddHighLowSeries( nCtrlId, nRegion, aData, nDataCount, aPPC, nPPCCount, nStyle, nWhichDataAxis, nColorLow, nColorHigh )
RMC_AddVolumeBarSeries( nCtrlId, nRegion, aData, nDataCount, aPPC, nPPCCount, nColor, nWhichDataAxis )
```

- High-low `aData`: open, high, low, close of each point. `nStyle` `RMC_OHLC` or `RMC_CANDLESTICK`.

## 4. Custom objects

Objects drawn over the chart, in pixels of the chart, after the series. Index 1 to 200; an index
already used is replaced.

```
RMC_COText( nCtrlId, nIndex, cText, nLeft, nTop, nWidth, nHeight, nStyle, nBgColor, nLineColor,
            nTransparency, nLineAlignment, nTextColor, cTextProperties )
RMC_COLine( nCtrlId, nIndex, aX, aY, nCount, nStyle, nColor, lSpline, nLineWidth, nStartCap, nEndCap )
```

- Text: width/height 0 = size of the text. `nStyle` box: `RMC_BOX_NONE` (text only), `RMC_BOX_FLAT`...
  `cTextProperties`: font size, `B` bold, `L` `C` `R` alignment, as `"9BL"`. Default 8, not bold, centered.
- Line: points in `aX` and `aY`. `nStyle` `RMC_LINE_FLAT`, `_FLAT_DOT`, `_FLAT_DASH`...; width 1 to 5
  (0 = 2); caps `RMC_ANCHOR_NONE`, `_ROUND`, `_BULLET`, `_ARROW_CLOSED`, `_ARROW_OPEN`.
- Not done yet: box, circle, dash, image, polygon, symbol, delete and visible (they return 0 and do nothing).

## 5. Output

```
RMC_Draw( nCtrlId )                                              // draw (window or memory)
RMC_Draw2File( nCtrlId, cFileName, nWidth, nHeight, nType )      // png, jpg, bmp, gif by extension
RMC_Draw2Clipboard( nCtrlId, nType )
RMC_Draw2Printer( nCtrlId, hPrinterDC, nLeft, nTop, nWidth, nHeight, nType )
RMC_DeleteChart( nCtrlId )                                       // free the chart and its window
RMC_Reset( nCtrlId )                                             // remove regions, series and objects
```

- Call `RMC_Draw()` after adding everything, and again after changes.
- `Draw2File()` width/height 0 = size of the chart.
- `Draw2Printer()` with hDC 0 shows the printer dialog and prints one page; with a hDC it only draws
  (StartDoc/StartPage are of the caller). Position and size in mm.
- `RMC_SetWatermark( cText, nColor, nLucent, nAlignment, nFontSize )`: text behind all charts.
- Console GT (GTWVT/GTWVG): call `CHC_ClipParent( hWnd )` so the console does not paint over the chart.

## 6. `.rmc` files

Charts made with the RMChart designer (`rmcdesigner.exe`) are saved as `.rmc` files.

```
RMC_CreateChartFromFile( hParent, nCtrlId, nX, nY, lExportOnly, cRMCFile )
RMC_GetChartSizeFromFile( cRMCFile, @nWidth, @nHeight )
RMC_File2Source( cRMCFile, [bText], [bData] ) --> cSource
```

- `cRMCFile` is the file name or the content itself.
- Data can be inside the file or in a `.csv` named in the file (relative to the `.rmc` folder).
- `RMC_File2Source()` returns Harbour source with the same `RMC_*()` calls, to use without the file.
  `bText` and `bData` can change texts and data while writing the source.
- Read: chart, regions, caption, grid, axes, legend, all series, custom text and line.

## 7. Constants and errors

All constants are in `include/ze_chartclass.ch`.

Colors: `RMC_COLOR_*` (as `RMC_COLOR_STEEL_BLUE`), or any ARGB value; a value without alpha is RGB.
`RMC_COLOR_DEFAULT` (0) = automatic, `RMC_COLOR_TRANSPARENT` = not drawn.

Errors:

| Code | Name | Meaning |
|---|---|---|
| 0 | `RMC_NO_ERROR` | ok |
| -3 | `RMC_ERROR_MAXSERIES` | too many series |
| -4 | `RMC_ERROR_ALLOC` | no memory |
| -5 | `RMC_ERROR_NODATA` | series without data |
| -6 | `RMC_ERROR_CTRLID` | chart id not found |
| -7 | `RMC_ERROR_SERIESINDEX` | wrong series |
| -8 | `RMC_ERROR_CREATEBITMAP` | bitmap not created |
| -9 | `RMC_ERROR_WRONGREGION` | wrong region |
| -11 | `RMC_ERROR_CREATEWINDOW` | window not created |
| -12 | `RMC_ERROR_INIGDIP` | GDI+ start failed |
| -13 | `RMC_ERROR_PRINT` | print failed |
| -14 | `RMC_ERROR_NOGDIP` | gdiplus.dll not found |
| -15 | `RMC_ERROR_RMCFILE` | `.rmc` file not found or empty |
| -24 | `RMC_ERROR_CLIPBOARD` | clipboard failed |
| -51 | `RMC_ERROR_CUSTOMINDEX` | custom object index not 1 to 200 |
