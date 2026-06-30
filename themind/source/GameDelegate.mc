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

    // Physical SELECT button opens the Action Menu or restarts if game finished
    function onSelect() as Boolean {
        System.println("onSelect event triggered");
        if (_view.status != :playing) {
            _view.resetGame();
            WatchUi.requestUpdate();
            return true;
        }
        openActionMenu();
        return true;
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

    function openActionMenu() as Void {
        playVibe(40, 100);
        var menu = new WatchUi.Menu2({:title => "Actions"});
        
        menu.addItem(new WatchUi.MenuItem("Next Level", "Level +1", :next_level, null));
        menu.addItem(new WatchUi.MenuItem("Prev Level", "Level -1", :prev_level, null));
        menu.addItem(new WatchUi.MenuItem("Lose Life", "Life -1", :lose_life, null));
        menu.addItem(new WatchUi.MenuItem("Gain Life", "Life +1", :gain_life, null));
        menu.addItem(new WatchUi.MenuItem("Use Shuriken", "Star -1", :use_star, null));
        menu.addItem(new WatchUi.MenuItem("Gain Shuriken", "Star +1", :gain_star, null));
        menu.addItem(new WatchUi.MenuItem("Reset Game", "Start over", :reset, null));
        
        var delegate = new TheMindMenuDelegate(_view);
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
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
        
        // If they tap in the middle vertical column or other zones, open the action menu
        System.println("Menu zone tapped. Opening menu...");
        openActionMenu();
        return true;
    }
}

class TheMindMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _view as GameView;

    function initialize(view as GameView) {
        Menu2InputDelegate.initialize();
        _view = view;
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        System.println("Menu item selected: " + id.toString());
        if (id == :next_level) {
            _view.changeLevel(1);
        } else if (id == :prev_level) {
            _view.changeLevel(-1);
        } else if (id == :lose_life) {
            _view.changeLives(-1);
        } else if (id == :gain_life) {
            _view.changeLives(1);
        } else if (id == :use_star) {
            _view.changeStars(-1);
        } else if (id == :gain_star) {
            _view.changeStars(1);
        } else if (id == :reset) {
            _view.resetGame();
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.requestUpdate();
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
