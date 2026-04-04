import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.SensorHistory;

class _9segmentsView extends WatchUi.WatchFace {

    private var _sevenSegment as SevenSegmentDigit?;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        // Tripled dimensions from 60x100 to 180x300, and 10 to 30 for thickness
        var width = 180;
        var height = 300;
        var thickness = 30;
        _sevenSegment = new SevenSegmentDigit(width, height, thickness, Graphics.COLOR_WHITE, Graphics.COLOR_DK_GRAY);
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

        if (_sevenSegment != null) {
            _sevenSegment.setColors(foregroundColor, inactiveColor);

            var screenWidth = dc.getWidth();
            var screenHeight = dc.getHeight();
            var digitWidth = 180;
            var digitHeight = 300;
            var spacing = 20;

            var y = (screenHeight - digitHeight) / 2;
            var totalWidth = digitWidth * 2 + spacing;
            var x = (screenWidth - totalWidth) / 2 - 45;

            // Always draw both positions, SevenSegmentDigit handles digits 0-9
            if (hour >= 10) {
                _sevenSegment.draw(dc, x, y, 1);
            }
            
            var secondDigitX = x + digitWidth + spacing;
            _sevenSegment.draw(dc, secondDigitX, y, hour % 10);

            // Draw minutes in the top hole of the second digit
            dc.setColor(foregroundColor, Graphics.COLOR_TRANSPARENT);
            var minuteString = minute.format("%02d");
            // FONT_NUMBER_HOT is larger than FONT_NUMBER_MEDIUM
            // Moved 15px down from digitHeight / 4
            dc.drawText(secondDigitX + digitWidth / 2, y + digitHeight / 4 + 15, Graphics.FONT_NUMBER_HOT, minuteString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            drawComplications(dc, x, y, digitHeight, foregroundColor);
        }
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

    private function drawComplications(dc as Dc, hourX as Number, hourY as Number, hourHeight as Number, color as Number) as Void {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps != null ? info.steps : 0;
        var cal = info.calories != null ? info.calories : 0;
        
        var hr = 0;
        var hrIter = ActivityMonitor.getHeartRateHistory(1, true);
        var hrSample = hrIter.next();
        if (hrSample != null && hrSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
            hr = hrSample.heartRate;
        }

        var temp = 0;
        if (SensorHistory has :getTemperatureHistory) {
            var tempIter = SensorHistory.getTemperatureHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
            var tempSample = tempIter.next();
            if (tempSample != null && tempSample.data != null) {
                temp = tempSample.data;
            }
        }

        // Target right-alignment at x=100
        var targetX = 100; 
        // We have 4 items. Let's use roughly 1/5th spacing.
        var spacing = hourHeight / 5;
        
        // 1. Heart rate (Top)
        drawComplication(dc, targetX, (hourY + spacing * 1.0).toNumber(), :hr, hr, color);
        // 2. Steps (Middle-ish)
        drawComplication(dc, targetX, (hourY + spacing * 2.0).toNumber(), :steps, steps, color);
        // 3. Calories (Next)
        drawComplication(dc, targetX, (hourY + spacing * 3.0).toNumber(), :cal, cal, color);
        // 4. Temperature (Bottom)
        drawComplication(dc, targetX, (hourY + spacing * 4.0).toNumber(), :temp, temp.toNumber(), color);
    }

    private function drawComplication(dc as Dc, rightX as Number, y as Number, type as Symbol, value as Number, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        
        var valStr = value.toString();
        var smallWidth = 10;
        var smallHeight = 16;
        var smallThickness = 2;
        var charSpacing = 2;
        
        var totalValueWidth = valStr.length() * (smallWidth + charSpacing);
        var iconWidth = 12;
        var padding = 5;
        var totalWidth = totalValueWidth + padding + iconWidth;
        
        var x = rightX - totalWidth;
        
        for (var i = 0; i < valStr.length(); i++) {
            var digitStr = valStr.substring(i, i+1);
            var digit = digitStr.toNumber();
            if (digit != null && _sevenSegment != null) {
                _sevenSegment.drawScaled(dc, x + i * (smallWidth + charSpacing), y - 2, digit, smallWidth, smallHeight, smallThickness);
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
