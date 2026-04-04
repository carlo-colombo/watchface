import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

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

        // drawGrid(dc);

        var clockTime = System.getClockTime();
        var hour = clockTime.hour;

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
            } else {
                // If it's single digit, we draw nothing in the first position
                // or we can pass a special value if we want to force "off"
                // For 12h clock, hours are 1-12.
                // The user said "drop the leading 0, only show it if is a 1"
                // But also "the digits should be fixed, indepently if it showing 1 or 2 digits"
                // This implies the 2nd digit stays in the same place.
            }
            _sevenSegment.draw(dc, x + digitWidth + spacing, y, hour % 10);
        }
    }

    private function drawGrid(dc as Dc) as Void {
        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
        var gridSpacing = 5;
        var gridColor = Graphics.COLOR_WHITE;

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
