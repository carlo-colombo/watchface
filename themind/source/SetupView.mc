import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class SetupView extends WatchUi.View {
    public var players as Number = 3; // 2, 3, or 4

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Custom drawing is done in onUpdate
    }

    function onUpdate(dc as Dc) as Void {
        // Clear screen with deep charcoal background
        dc.setColor(0x121212, 0x121212);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();

        // 1. Draw Title "THE MIND"
        dc.setColor(0x00AAFF, Graphics.COLOR_TRANSPARENT); // Ice blue
        dc.drawText(w / 2, h * 0.18, Graphics.FONT_LARGE, "THE MIND", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 2. Draw subtitle "SELECT PLAYERS"
        dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.32, Graphics.FONT_XTINY, "SELECT PLAYERS", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 3. Draw Player Selection controls in the center
        // Draw Left Arrow "<" button outline and text
        dc.setColor(players > 2 ? 0xFFFFFF : 0x444444, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w * 0.20, h * 0.48, Graphics.FONT_MEDIUM, "<", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw Player Count
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.48, Graphics.FONT_NUMBER_MEDIUM, players.toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw Right Arrow ">" button outline and text
        dc.setColor(players < 4 ? 0xFFFFFF : 0x444444, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w * 0.80, h * 0.48, Graphics.FONT_MEDIUM, ">", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 4. Draw Starting Info Box below player selection
        var startingLives = getStartingLives();
        var totalLevels = getTotalLevels();

        var infoStr = startingLives.toString() + " LIVES  |  1 STAR  |  " + totalLevels.toString() + " LVLS";
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.68, Graphics.FONT_XTINY, infoStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 5. Draw START button at the bottom
        // Draw pill-shaped button container
        var btnW = w * 0.45;
        var btnH = h * 0.12;
        var btnX = (w - btnW) / 2;
        var btnY = h * 0.78;
        
        dc.setColor(0x00AAFF, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(btnX, btnY, btnW, btnH, 8);
        
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, btnY + btnH / 2, Graphics.FONT_TINY, "START", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function getStartingLives() as Number {
        if (players == 2) {
            return 2;
        } else if (players == 3) {
            return 3;
        } else {
            return 4;
        }
    }

    function getTotalLevels() as Number {
        if (players == 2) {
            return 12;
        } else if (players == 3) {
            return 10;
        } else {
            return 8;
        }
    }
}
