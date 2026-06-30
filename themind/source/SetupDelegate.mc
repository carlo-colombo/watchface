import Toybox.WatchUi;
import Toybox.System;
import Toybox.Attention;
import Toybox.Lang;

class SetupDelegate extends WatchUi.BehaviorDelegate {
    private var _view as SetupView;

    function initialize(view as SetupView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function playVibe(intensity as Number, duration as Number) as Void {
        if (Attention has :vibrate) {
            var vibe = [ new Attention.VibeProfile(intensity, duration) ];
            Attention.vibrate(vibe);
        }
    }

    function onNextPage() as Boolean {
        if (_view.players < 4) {
            _view.players++;
            WatchUi.requestUpdate();
            playVibe(30, 80);
        }
        return true;
    }

    function onPreviousPage() as Boolean {
        if (_view.players > 2) {
            _view.players--;
            WatchUi.requestUpdate();
            playVibe(30, 80);
        }
        return true;
    }

    function onSelect() as Boolean {
        startGame();
        return true;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        var w = System.getDeviceSettings().screenWidth;
        var h = System.getDeviceSettings().screenHeight;

        if (x < w * 0.35 && y > h * 0.40 && y < h * 0.58) {
            if (_view.players > 2) {
                _view.players--;
                WatchUi.requestUpdate();
                playVibe(30, 80);
            }
            return true;
        } else if (x > w * 0.65 && y > h * 0.40 && y < h * 0.58) {
            if (_view.players < 4) {
                _view.players++;
                WatchUi.requestUpdate();
                playVibe(30, 80);
            }
            return true;
        } else if (y > h * 0.70) {
            startGame();
            return true;
        }
        return false;
    }

    function startGame() as Void {
        playVibe(50, 150);
        var gameView = new GameView(_view.players);
        var gameDelegate = new GameDelegate(gameView);
        WatchUi.pushView(gameView, gameDelegate, WatchUi.SLIDE_LEFT);
    }
}
