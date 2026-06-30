import Toybox.WatchUi;
import Toybox.System;
import Toybox.Attention;
import Toybox.Lang;

class GameDelegate extends WatchUi.BehaviorDelegate {
    private var _view as GameView;

    function initialize(view as GameView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function playVibe(intensity as Number, duration as Number) as Void {
        if (Attention has :vibrate) {
            var vibe = [ new Attention.VibeProfile(intensity, duration) ];
            Attention.vibrate(vibe);
        }
    }

    // Physical SELECT button restarts if game finished
    function onSelect() as Boolean {
        System.println("onSelect event triggered");
        if (_view.status != :playing) {
            _view.resetGame();
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }

    // Physical BACK button returns to Setup screen
    function onBack() as Boolean {
        System.println("onBack event triggered");
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    // Physical UP button: shortcuts to increment level
    function onPreviousPage() as Boolean {
        System.println("onPreviousPage (UP) event triggered");
        if (_view.status == :playing) {
            _view.changeLevel(1);
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }

    // Physical DOWN button: shortcuts to decrement level
    function onNextPage() as Boolean {
        System.println("onNextPage (DOWN) event triggered");
        if (_view.status == :playing) {
            _view.changeLevel(-1);
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var tx = coords[0];
        var ty = coords[1];
        
        var w = System.getDeviceSettings().screenWidth;
        var h = System.getDeviceSettings().screenHeight;

        System.println("onTap registered at: [" + tx + ", " + ty + "] on screen size: [" + w + "x" + h + "]");

        if (_view.status != :playing) {
            // Check if tap was on the Restart button at the bottom (Y > 70%)
            var btnW = w * 0.5;
            var btnH = h * 0.12;
            var btnX = (w - btnW) / 2;
            var btnY = h * 0.74;
            if (tx >= btnX && tx <= btnX + btnW && ty >= btnY && ty <= btnY + btnH) {
                System.println("Restart button tapped!");
                _view.resetGame();
                WatchUi.requestUpdate();
                return true;
            }
            return false;
        }

        // Bounding box logic for the three interactive rows
        // Row 1 (Level) Y bounds: 15% to 38%
        if (ty >= h * 0.15 && ty < h * 0.38) {
            if (tx < w * 0.35) {
                System.println("Level '-' tapped");
                _view.changeLevel(-1);
                WatchUi.requestUpdate();
                return true;
            } else if (tx > w * 0.65) {
                System.println("Level '+' tapped");
                _view.changeLevel(1);
                WatchUi.requestUpdate();
                return true;
            }
        }
        // Row 2 (Lives) Y bounds: 39% to 61%
        else if (ty >= h * 0.39 && ty < h * 0.61) {
            if (tx < w * 0.35) {
                System.println("Lives '-' tapped");
                _view.changeLives(-1);
                WatchUi.requestUpdate();
                return true;
            } else if (tx > w * 0.65) {
                System.println("Lives '+' tapped");
                _view.changeLives(1);
                WatchUi.requestUpdate();
                return true;
            }
        }
        // Row 3 (Stars) Y bounds: 62% to 85%
        else if (ty >= h * 0.62 && ty < h * 0.85) {
            if (tx < w * 0.35) {
                System.println("Stars '-' tapped");
                _view.changeStars(-1);
                WatchUi.requestUpdate();
                return true;
            } else if (tx > w * 0.65) {
                System.println("Stars '+' tapped");
                _view.changeStars(1);
                WatchUi.requestUpdate();
                return true;
            }
        }
        
        System.println("Tap in dead zone - ignoring");
        return false;
    }
}

