import Toybox.Graphics;
import Toybox.Lang;

class SevenSegmentDigit {
    private var _width as Number;
    private var _height as Number;
    private var _thickness as Number;
    private var _color as Number;
    private var _inactiveColor as Number;

    private static const DIGITS = [
        [true,  true,  true,  true,  true,  true,  false], // 0
        [false, true,  true,  false, false, false, false], // 1
        [true,  true,  false, true,  true,  false, true ], // 2
        [true,  true,  true,  true,  false, false, true ], // 3
        [false, true,  true,  false, false, true,  true ], // 4
        [true,  false, true,  true,  false, true,  true ], // 5
        [true,  false, true,  true,  true,  true,  true ], // 6
        [true,  true,  true,  false, false, false, false], // 7
        [true,  true,  true,  true,  true,  true,  true ], // 8
        [true,  true,  true,  true,  false, true,  true ]  // 9
    ];

    function initialize(width as Number, height as Number, thickness as Number, color as Number, inactiveColor as Number) {
        _width = width;
        _height = height;
        _thickness = thickness;
        _color = color;
        _inactiveColor = inactiveColor;
    }

    function setColors(color as Number, inactiveColor as Number) as Void {
        _color = color;
        _inactiveColor = inactiveColor;
    }

    function draw(dc as Dc, x as Number, y as Number, digit as Number) as Void {
        if (digit < 0 || digit > 9) {
            return;
        }

        var segments = DIGITS[digit];
        var t = _thickness;
        var w = _width;
        var h = _height;
        var h2 = h / 2;

        // A (Top)
        drawHorizontalSegment(dc, x + t/2, y, w - t, segments[0]);
        // B (Top-Right)
        drawVerticalSegment(dc, x + w - t, y + t/2, h2 - t, segments[1]);
        // C (Bottom-Right)
        drawVerticalSegment(dc, x + w - t, y + h2 + t/2, h2 - t, segments[2]);
        // D (Bottom)
        drawHorizontalSegment(dc, x + t/2, y + h - t, w - t, segments[3]);
        // E (Bottom-Left)
        drawVerticalSegment(dc, x, y + h2 + t/2, h2 - t, segments[4]);
        // F (Top-Left)
        drawVerticalSegment(dc, x, y + t/2, h2 - t, segments[5]);
        // G (Middle)
        drawHorizontalSegment(dc, x + t/2, y + h2 - t/2, w - t, segments[6]);
    }

    private function drawHorizontalSegment(dc as Dc, x as Number, y as Number, w as Number, active as Boolean) as Void {
        if (active) {
            dc.setColor(_color, Graphics.COLOR_TRANSPARENT);
        } else if (_inactiveColor != null) {
            dc.setColor(_inactiveColor, Graphics.COLOR_TRANSPARENT);
        } else {
            return;
        }

        var t = _thickness;
        var points = [
            [x + t/2, y],
            [x + w - t/2, y],
            [x + w, y + t/2],
            [x + w - t/2, y + t],
            [x + t/2, y + t],
            [x, y + t/2]
        ];
        dc.fillPolygon(points);
    }

    private function drawVerticalSegment(dc as Dc, x as Number, y as Number, h as Number, active as Boolean) as Void {
        if (active) {
            dc.setColor(_color, Graphics.COLOR_TRANSPARENT);
        } else if (_inactiveColor != null) {
            dc.setColor(_inactiveColor, Graphics.COLOR_TRANSPARENT);
        } else {
            return;
        }

        var t = _thickness;
        var points = [
            [x + t/2, y],
            [x + t, y + t/2],
            [x + t, y + h - t/2],
            [x + t/2, y + h],
            [x, y + h - t/2],
            [x, y + t/2]
        ];
        dc.fillPolygon(points);
    }
}
