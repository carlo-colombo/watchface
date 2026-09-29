import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class Background extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc as Dc) as Void {
        // Set the background color then call to clear the screen
        var backgroundValue = Application.Properties.getValue("BackgroundColor");
        var backgroundColor = backgroundValue != null ? backgroundValue as Number : Graphics.COLOR_BLACK;
        dc.setColor(Graphics.COLOR_TRANSPARENT, backgroundColor);
        dc.clear();
    }

}
