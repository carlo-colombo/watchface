import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.SensorHistory;
import Toybox.Time;
import Toybox.Time.Gregorian;

class _9segmentsView extends WatchUi.WatchFace {

    private var _currentFontType as Number = -1;
    private var _font as FontResource?;
    private var _fontMedium as FontResource?;
    private var _fontSmall as FontResource?;
    private var _fontDate as FontResource?;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        updateFonts();
    }

    private function updateFonts() as Void {
        var fontType = Application.Properties.getValue("FontType") as Number;
        if (fontType != _currentFontType) {
            _currentFontType = fontType;
            if (fontType == 0) {
                _font = WatchUi.loadResource(Rez.Fonts.DSEG7_Classic);
                _fontMedium = WatchUi.loadResource(Rez.Fonts.DSEG7_Classic_Medium);
                _fontSmall = WatchUi.loadResource(Rez.Fonts.DSEG7_Classic_Small);
                _fontDate = WatchUi.loadResource(Rez.Fonts.DSEG14_Classic_Date);
            } else if (fontType == 1) {
                _font = WatchUi.loadResource(Rez.Fonts.DSEG7_ClassicMini);
                _fontMedium = WatchUi.loadResource(Rez.Fonts.DSEG7_ClassicMini_Medium);
                _fontSmall = WatchUi.loadResource(Rez.Fonts.DSEG7_ClassicMini_Small);
                _fontDate = WatchUi.loadResource(Rez.Fonts.DSEG14_ClassicMini_Date);
            } else if (fontType == 2) {
                _font = WatchUi.loadResource(Rez.Fonts.DSEG7_Modern);
                _fontMedium = WatchUi.loadResource(Rez.Fonts.DSEG7_Modern_Medium);
                _fontSmall = WatchUi.loadResource(Rez.Fonts.DSEG7_Modern_Small);
                _fontDate = WatchUi.loadResource(Rez.Fonts.DSEG14_Modern_Date);
            } else if (fontType == 3) {
                _font = WatchUi.loadResource(Rez.Fonts.DSEG7_ModernMini);
                _fontMedium = WatchUi.loadResource(Rez.Fonts.DSEG7_ModernMini_Medium);
                _fontSmall = WatchUi.loadResource(Rez.Fonts.DSEG7_ModernMini_Small);
                _fontDate = WatchUi.loadResource(Rez.Fonts.DSEG14_ModernMini_Date);
            }
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        updateFonts();

        if (Application.Properties.getValue("ShowGrid")) {
            drawGrid(dc);
        }

        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        var minute = clockTime.min;

        // Force 12h clock
        if (hour > 12) {
            hour = hour - 12;
        } else if (hour == 0) {
            hour = 12;
        }

        var foregroundColor = Application.Properties.getValue("ForegroundColor") as Number;

        // Calculate a dimmed inactive color (roughly 1/8 brightness)
        var r = (foregroundColor >> 16) & 0xFF;
        var g = (foregroundColor >> 8) & 0xFF;
        var b = foregroundColor & 0xFF;
        var inactiveColor = ((r / 8) << 16) | ((g / 8) << 8) | (b / 8);

        drawDate(dc, foregroundColor, inactiveColor);

        if (_font != null) {
            var screenWidth = dc.getWidth();
            var screenHeight = dc.getHeight();
            
            // DSEG7 font at size 280 is 241x281
            var digitWidth = 241;
            var digitHeight = 281;
            var spacing = 10;

            var y = (screenHeight - digitHeight) / 2;
            var totalWidth = digitWidth * 2 + spacing;
            var x = (screenWidth - totalWidth) / 2 - 30;

            var firstDigitX = x + 15;
            var secondDigitX = x + digitWidth + spacing - 30;

            // Tens place: always show '1' as background
            dc.setColor(inactiveColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(firstDigitX, y, _font, "!", Graphics.TEXT_JUSTIFY_LEFT);
            dc.drawText(firstDigitX, y, _font, "1", Graphics.TEXT_JUSTIFY_LEFT);
            if (hour >= 10) {
                dc.setColor(foregroundColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(firstDigitX, y, _font, "1", Graphics.TEXT_JUSTIFY_LEFT);
            }
            
            // Background '8' for ones place
            dc.setColor(inactiveColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(secondDigitX, y, _font, "8", Graphics.TEXT_JUSTIFY_LEFT);
            drawDigit(dc, secondDigitX, y, hour % 10, _font, foregroundColor, inactiveColor);

            // Draw minutes in the top hole of the second digit
            if (_fontMedium != null) {
                var minuteString = minute.format("%02d");
                var mDigitWidth = 62;
                var mSpacing = 2;
                var mTotalWidth = mDigitWidth * 2 + mSpacing;
                
                // Position inside the top hole
                var mx = secondDigitX + (digitWidth - mTotalWidth) / 2;
                var my = y + 40; // Moved 10px up from y + 50
                
                for (var i = 0; i < minuteString.length(); i++) {
                    var mDigit = minuteString.substring(i, i+1).toNumber();
                    if (mDigit != null) {
                        drawDigit(dc, (mx + i * (mDigitWidth + mSpacing)).toNumber(), my, mDigit, _fontMedium, foregroundColor, inactiveColor);
                    }
                }
            }

            drawComplications(dc, x, y, digitHeight, foregroundColor, inactiveColor);
            drawBattery(dc, screenWidth / 2, screenHeight - 25, foregroundColor, inactiveColor);
        }
    }

    private function drawDate(dc as Dc, color as Number, inactiveColor as Number) as Void {
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var dateStr = info.day.format("%02d") + " " + info.month.format("%02d");
        
        if (_fontDate != null) {
            var x = dc.getWidth() / 2;
            var y = 20; // Top of screen
            
            dc.setColor(inactiveColor, Graphics.COLOR_TRANSPARENT);
            // "!" is all segments on for DSEG14 as well in most cases
            dc.drawText(x, y, _fontDate, "!!!!!", Graphics.TEXT_JUSTIFY_CENTER);
            
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, _fontDate, dateStr, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    private function drawBattery(dc as Dc, x as Number, y as Number, color as Number, inactiveColor as Number) as Void {
        var battery = System.getSystemStats().battery;
        var width = 40;
        var height = 20;
        var xStart = x - width / 2;
        var yStart = y - height / 2;

        // Draw battery outline
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(xStart, yStart, width, height);
        // Draw battery terminal
        dc.fillRectangle(xStart + width, yStart + height / 4, 3, height / 2);

        // Draw fill
        var fillWidth = ((width - 4) * (battery / 100.0)).toNumber();
        if (battery > 10) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(xStart + 2, yStart + 2, fillWidth, height - 4);
        
        // Background fill (dimmed)
        if (fillWidth < width - 4) {
            dc.setColor(inactiveColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(xStart + 2 + fillWidth, yStart + 2, (width - 4) - fillWidth, height - 4);
        }
    }

    private function drawDigit(dc as Dc, x as Number, y as Number, digit as Number, font as FontResource, color as Number, inactiveColor as Number) as Void {
        // Draw background "all-off" segments
        dc.setColor(inactiveColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, "!", Graphics.TEXT_JUSTIFY_LEFT);
        // Draw actual digit segments
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, digit.toString(), Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function drawGrid(dc as Dc) as Void {
        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
        var gridSpacing = 10;
        var gridColor = 0x888888; // Half-white/Gray

        dc.setColor(gridColor, Graphics.COLOR_TRANSPARENT);

        // Vertical lines
        for (var x = 0; x < screenWidth; x += gridSpacing) {
            dc.drawLine(x, 0, x, screenHeight);
        }

        // Horizontal lines
        for (var y = 0; y < screenHeight; y += gridSpacing) {
            dc.drawLine(0, y, screenWidth, y);
        }
    }

    private function drawComplications(dc as Dc, hourX as Number, hourY as Number, hourHeight as Number, color as Number, inactiveColor as Number) as Void {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps != null ? info.steps : 0;
        var cal = info.calories != null ? info.calories : 0;
        
        var hr = 0;
        var hrIter = ActivityMonitor.getHeartRateHistory(1, true);
        var hrSample = hrIter.next();
        if (hrSample != null && hrSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
            hr = hrSample.heartRate;
        }

        // Target right-alignment at x=100
        var targetX = 100; 
        // We have 3 items. Let's use 1/4th spacing to center them vertically.
        var spacing = hourHeight / 4;
        
        // 1. Heart rate (Top)
        drawComplication(dc, targetX, (hourY + spacing * 1.0).toNumber(), :hr, hr, color, inactiveColor);
        // 2. Steps (Middle)
        drawComplication(dc, targetX, (hourY + spacing * 2.0).toNumber(), :steps, steps, color, inactiveColor);
        // 3. Calories (Bottom)
        drawComplication(dc, targetX, (hourY + spacing * 3.0).toNumber(), :cal, cal, color, inactiveColor);
    }

    private function drawComplication(dc as Dc, rightX as Number, y as Number, type as Symbol, value as Number, color as Number, inactiveColor as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        
        var valStr = value.toString();
        // DSEG7 small size was 20. Let's check dimensions for size 20.
        // It's roughly 16x20.
        var smallWidth = 16;
        var charSpacing = 2;
        
        var totalValueWidth = valStr.length() * (smallWidth + charSpacing);
        var iconWidth = 12;
        var padding = 5;
        var totalWidth = totalValueWidth + padding + iconWidth;
        
        var x = rightX - totalWidth;
        
        if (_fontSmall != null) {
            for (var i = 0; i < valStr.length(); i++) {
                var digitStr = valStr.substring(i, i+1);
                var digit = digitStr.toNumber();
                if (digit != null) {
                    drawDigit(dc, x + i * (smallWidth + charSpacing), y - 2, digit, _fontSmall, color, inactiveColor);
                }
            }
        }

        // Draw icon after the numbers - ENSURE foreground color is set
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        drawIcon(dc, x + totalValueWidth + padding, y, type);
    }

    private function drawIcon(dc as Dc, x as Number, y as Number, type as Symbol) as Void {
        if (type == :steps) {
            // Simple footprint symbol
            dc.fillRectangle(x, y + 4, 4, 6);
            dc.fillRectangle(x + 5, y, 4, 6);
        } else if (type == :hr) {
            // Simple heart symbol
            var pts = [
                [x + 6, y + 10], [x, y + 4], [x + 3, y], [x + 6, y + 3], [x + 9, y], [x + 12, y + 4]
            ];
            dc.fillPolygon(pts);
        } else if (type == :temp) {
            // Simple thermometer symbol
            dc.fillRectangle(x + 4, y, 4, 8);
            dc.fillCircle(x + 6, y + 10, 4);
        } else if (type == :cal) {
            // Simple flame/calorie symbol
            var pts = [
                [x + 6, y],
                [x + 2, y + 6],
                [x + 2, y + 12],
                [x + 6, y + 16],
                [x + 10, y + 12],
                [x + 10, y + 6]
            ];
            dc.fillPolygon(pts);
            dc.fillCircle(x + 6, y + 10, 3);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
