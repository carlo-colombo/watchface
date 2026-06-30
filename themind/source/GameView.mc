import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Attention;
import Toybox.Timer;

class GameView extends WatchUi.View {
    public var players as Number;
    public var maxLevel as Number;
    public var level as Number = 1;
    public var lives as Number = 2;
    public var stars as Number = 1;
    public var status as Symbol = :playing; // :playing, :game_over, :game_won

    private var _rewardTimer as Timer.Timer? = null;
    public var rewardMessage as String? = null;

    function initialize(playersCount as Number) {
        View.initialize();
        players = playersCount;
        if (players == 2) {
            lives = 2;
            maxLevel = 12;
        } else if (players == 3) {
            lives = 3;
            maxLevel = 10;
        } else {
            lives = 4;
            maxLevel = 8;
        }
    }

    function onLayout(dc as Dc) as Void {
        // Custom drawing is done in onUpdate
    }

    function onHide() as Void {
        if (_rewardTimer != null) {
            _rewardTimer.stop();
            _rewardTimer = null;
        }
    }

    function onUpdate(dc as Dc) as Void {
        // Clear screen with deep charcoal background
        dc.setColor(0x121212, 0x121212);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();

        if (status == :game_over) {
            // Draw Game Over Screen
            dc.setColor(0xFF3366, Graphics.COLOR_TRANSPARENT); // Red
            dc.drawText(w / 2, h * 0.35, Graphics.FONT_LARGE, "GAME OVER", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h * 0.52, Graphics.FONT_TINY, "Reached Level " + level.toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            // Draw restart button
            var btnW = w * 0.5;
            var btnH = h * 0.12;
            var btnX = (w - btnW) / 2;
            var btnY = h * 0.74;
            dc.setColor(0xFF3366, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(btnX, btnY, btnW, btnH, 8);
            dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, btnY + btnH / 2, Graphics.FONT_TINY, "RESTART", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        if (status == :game_won) {
            // Draw Game Won Screen
            dc.setColor(0x00FF66, Graphics.COLOR_TRANSPARENT); // Green
            dc.drawText(w / 2, h * 0.35, Graphics.FONT_LARGE, "VICTORY!", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h * 0.52, Graphics.FONT_TINY, "The Mind Completed!", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            // Draw restart button
            var btnW = w * 0.5;
            var btnH = h * 0.12;
            var btnX = (w - btnW) / 2;
            var btnY = h * 0.74;
            dc.setColor(0x00FF66, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(btnX, btnY, btnW, btnH, 8);
            dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, btnY + btnH / 2, Graphics.FONT_TINY, "RESTART", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        // Draw Interactive Game Rows
        var lvlY = h * 0.28;
        var lvsY = h * 0.50;
        var strY = h * 0.72;

        var btnLeftX = w * 0.20;
        var btnRightX = w * 0.80;

        // Row 1: Level
        drawButton(dc, btnLeftX, lvlY, "-");
        dc.setColor(0x00AAFF, Graphics.COLOR_TRANSPARENT); // Blue
        dc.drawText(w / 2, lvlY, Graphics.FONT_MEDIUM, "LVL " + level.toString() + "/" + maxLevel.toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        drawButton(dc, btnRightX, lvlY, "+");

        // Row 2: Lives
        drawButton(dc, btnLeftX, lvsY, "-");
        drawHeart(dc, w * 0.43, lvsY, 18.0);
        dc.setColor(0xFF3366, Graphics.COLOR_TRANSPARENT); // Crimson
        dc.drawText(w * 0.54, lvsY, Graphics.FONT_MEDIUM, "x" + lives.toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        drawButton(dc, btnRightX, lvsY, "+");

        // Row 3: Stars
        drawButton(dc, btnLeftX, strY, "-");
        drawStar(dc, w * 0.43, strY, 18.0);
        dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT); // Gold
        dc.drawText(w * 0.54, strY, Graphics.FONT_MEDIUM, "x" + stars.toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        drawButton(dc, btnRightX, strY, "+");

        // Draw Menu instruction
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.88, Graphics.FONT_XTINY, "SELECT FOR MENU", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw Reward Notification Banner if active
        if (rewardMessage != null) {
            var bannerW = w * 0.75;
            var bannerH = h * 0.24;
            var bannerX = (w - bannerW) / 2;
            var bannerY = (h - bannerH) / 2;

            // Semi-transparent overlay box
            dc.setColor(0x1F1F1F, 0x1F1F1F);
            dc.fillRoundedRectangle(bannerX, bannerY, bannerW, bannerH, 12);
            dc.setColor(0x00AAFF, Graphics.COLOR_TRANSPARENT);
            dc.drawRoundedRectangle(bannerX, bannerY, bannerW, bannerH, 12);

            dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT); // Gold
            dc.drawText(w / 2, bannerY + bannerH * 0.28, Graphics.FONT_TINY, "LEVEL REWARD!", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, bannerY + bannerH * 0.68, Graphics.FONT_SMALL, rewardMessage as String, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function drawButton(dc as Dc, x as Float, y as Float, label as String) as Void {
        dc.setColor(0x2A2A2A, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, 18);
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, Graphics.FONT_TINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawHeart(dc as Dc, x as Float, y as Float, size as Float) as Void {
        dc.setColor(0xFF3366, Graphics.COLOR_TRANSPARENT);
        // Left circle
        dc.fillCircle((x - size / 4).toNumber(), (y - size / 4).toNumber(), (size / 4).toNumber());
        // Right circle
        dc.fillCircle((x + size / 4).toNumber(), (y - size / 4).toNumber(), (size / 4).toNumber());
        // Bottom triangle
        var points = [
            [(x - size / 2 + 1).toNumber(), (y - size / 8).toNumber()],
            [(x + size / 2 - 1).toNumber(), (y - size / 8).toNumber()],
            [x.toNumber(), (y + size / 2).toNumber()]
        ];
        dc.fillPolygon(points);
    }

    private function drawStar(dc as Dc, x as Float, y as Float, size as Float) as Void {
        dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
        var points = [
            [x.toNumber(), (y - size / 2).toNumber()],
            [(x + size / 6).toNumber(), (y - size / 6).toNumber()],
            [(x + size / 2).toNumber(), y.toNumber()],
            [(x + size / 6).toNumber(), (y + size / 6).toNumber()],
            [x.toNumber(), (y + size / 2).toNumber()],
            [(x - size / 6).toNumber(), (y + size / 6).toNumber()],
            [(x - size / 2).toNumber(), y.toNumber()],
            [(x - size / 6).toNumber(), (y - size / 6).toNumber()]
        ];
        dc.fillPolygon(points);
    }

    function playVibe(intensity as Number, duration as Number) as Void {
        if (Attention has :vibrate) {
            var vibe = [ new Attention.VibeProfile(intensity, duration) ];
            Attention.vibrate(vibe);
        }
    }

    function checkLevelReward(completedLevel as Number) as Symbol {
        if (completedLevel == 2 || completedLevel == 5 || completedLevel == 8) {
            if (stars < 3) {
                stars++;
                return :star;
            }
        } else if (completedLevel == 3 || completedLevel == 6 || completedLevel == 9) {
            if (lives < 5) {
                lives++;
                return :life;
            }
        }
        return :none;
    }

    function changeLevel(delta as Number) as Void {
        if (status != :playing) { return; }
        
        var nextLevel = level + delta;
        if (nextLevel > maxLevel) {
            status = :game_won;
            playVibe(80, 500);
            return;
        }
        
        if (nextLevel < 1) {
            level = 1;
            playVibe(30, 80);
            return;
        }

        level = nextLevel;

        if (delta > 0) {
            var completedLevel = level - 1;
            var reward = checkLevelReward(completedLevel);
            if (reward == :star) {
                showReward("+1 SHURIKEN!");
                playVibe(60, 200);
            } else if (reward == :life) {
                showReward("+1 LIFE!");
                playVibe(60, 200);
            } else {
                playVibe(40, 100);
            }
        } else {
            playVibe(30, 80);
        }
    }

    function changeLives(delta as Number) as Void {
        if (status != :playing) { return; }
        lives += delta;
        if (lives > 5) {
            lives = 5;
            playVibe(30, 80);
        } else if (lives <= 0) {
            lives = 0;
            status = :game_over;
            playVibe(90, 600);
        } else {
            playVibe(40, 100);
        }
    }

    function changeStars(delta as Number) as Void {
        if (status != :playing) { return; }
        stars += delta;
        if (stars > 3) {
            stars = 3;
            playVibe(30, 80);
        } else if (stars < 0) {
            stars = 0;
            playVibe(30, 80);
        } else {
            playVibe(40, 100);
        }
    }

    function resetGame() as Void {
        level = 1;
        stars = 1;
        status = :playing;
        rewardMessage = null;
        if (players == 2) {
            lives = 2;
        } else if (players == 3) {
            lives = 3;
        } else {
            lives = 4;
        }
        playVibe(50, 200);
    }

    function showReward(message as String) as Void {
        rewardMessage = message;
        if (_rewardTimer == null) {
            _rewardTimer = new Timer.Timer();
        }
        _rewardTimer.stop();
        _rewardTimer.start(method(:clearRewardMessage), 2500, false);
    }

    function clearRewardMessage() as Void {
        rewardMessage = null;
        WatchUi.requestUpdate();
    }
}
