package;

import axollib.AxolAPI;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxMath;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.utils.Object;

class GameOver extends FlxSubState
{
    public var letters:Array<String> = [
        " ", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2",
        "3", "4", "5", "6", "7", "8", "9", "!"
    ];

    private var back:FlxSprite;
    private var frame:FlxSprite;

    public var ready:Bool = false;
    public var scene:FlxSprite;
    public var text:FlxBitmapText;
    public var gameOverText:String = "~ Game Over ~";
    public var gameWinText:String = "~ Victory ~";
    public var whichText:String;
    public var tCount:Int = 0;
    public var score:Int = 0;

    public var stats:Array<String> = [];

    public var txtInits:Array<FlxBitmapText>;
    public var initVals:Array<Int>;
    public var cursor:FlxBitmapText;
    public var sel:Int = 0;

    public var font:FlxBitmapFont;

    public function new(IsWin:Bool, Score:Int)
    {
        super();

        ready = false;

        font = FlxBitmapFont.fromAngelCode(AssetPaths.simple_font__png, AssetPaths.simple_font__xml);

        initVals = [0, 0, 0];
        initVals[0] = getVal(Globals.Save.data.init.charAt(0));
        initVals[1] = getVal(Globals.Save.data.init.charAt(1));
        initVals[2] = getVal(Globals.Save.data.init.charAt(2));

        score = Score;

        back = new FlxSprite();
        back.makeGraphic(FlxG.width, FlxG.height, 0x66000000);
        back.alpha = 0;

        add(back);

        frame = new FlxSprite(0, 0,
            AssetPaths.screen_frame__png); // FlxSliceSprite(AssetPaths.dark_frame__png, new FlxRect(2, 2, 2, 2), FlxG.width - 8, FlxG.height - 8);
        frame.screenCenter(FlxAxes.XY);
        frame.alpha = 0;
        add(frame);

        scene = new FlxSprite();

        text = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.fancy_font__png, AssetPaths.fancy_font__xml));
        text.text = "";
        text.borderColor = 0xff333333;
        text.borderSize = 1;
        text.borderStyle = FlxTextBorderStyle.SHADOW;
        text.autoSize = false;

        if (IsWin)
        {
            whichText = gameWinText;

            scene.loadGraphic(AssetPaths.victory_scene__png, true, 110, 40);
            scene.animation.add("play", [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 0], 8, false);
            text.x = 52.5;
            text.fieldWidth = 57;
        }
        else
        {
            whichText = gameOverText;
            scene.loadGraphic(AssetPaths.game_over_scene__png, true, 110, 40);
            scene.animation.add("play", [
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 6
            ], 8, false);
            text.x = 44.5;
            text.fieldWidth = 73;
        }

        scene.alpha = 0;
        scene.screenCenter(FlxAxes.X);
        scene.y = frame.y + 2;
        add(scene);

        text.y = scene.y + scene.height - 10;

        add(text);

        /*

         */
    }

    private function getVal(Char:String):Int
    {
        for (i in 0...letters.length)
        {
            if (letters[i] == Char)
                return i;
        }
        return -1;
    }

    private function advanceText(T:FlxTimer):Void
    {
        if (whichText.charAt(text.text.length) == " ")
            text.text += whichText.charAt(text.text.length);
        text.text += whichText.charAt(text.text.length);

        if (text.text.length < whichText.length)
        {
            T.start(.33, advanceText);
        }
    }

    private function showStat(T:FlxTimer):Void
    {
        var s:String = stats.shift();
        var t:FlxBitmapText = new FlxBitmapText(font);
        t.borderColor = 0xff111111;
        t.borderSize = 1;
        t.borderStyle = FlxTextBorderStyle.SHADOW;
        t.text = s;
        t.screenCenter(FlxAxes.X);
        t.y = scene.y + scene.height + 2 + (9 * tCount);
        tCount++;
        add(t);
        if (stats.length > 0)
            T.start(.33, showStat);
        else
        {
            t.color = FlxColor.YELLOW;
            T.start(.33, function(_)
            {
                var m:FlxBitmapText = new FlxBitmapText(font);
                m.borderColor = 0xff111111;
                m.borderSize = 1;
                m.borderStyle = FlxTextBorderStyle.SHADOW;
                m.text = "Enter Initials:";

                m.y = scene.y + scene.height + 2 + (9 * tCount);
                add(m);

                txtInits = [];
                var init:FlxBitmapText = new FlxBitmapText(font);
                init.alignment = FlxTextAlign.CENTER;
                init.autoSize = false;
                init.fieldWidth = 5;
                init.text = letters[initVals[0]];
                init.y = m.y;
                init.borderColor = 0xff111111;
                init.borderSize = 1;
                init.borderStyle = FlxTextBorderStyle.SHADOW;
                txtInits.push(init);
                add(init);

                init = new FlxBitmapText(font);
                init.alignment = FlxTextAlign.CENTER;
                init.autoSize = false;
                init.fieldWidth = 5;
                init.text = letters[initVals[1]];
                init.y = m.y;
                init.borderColor = 0xff111111;
                init.borderSize = 1;
                init.borderStyle = FlxTextBorderStyle.SHADOW;
                txtInits.push(init);
                add(init);

                init = new FlxBitmapText(font);
                init.alignment = FlxTextAlign.CENTER;
                init.autoSize = false;
                init.fieldWidth = 5;
                init.text = letters[initVals[2]];
                init.y = m.y;
                init.borderColor = 0xff111111;
                init.borderSize = 1;
                init.borderStyle = FlxTextBorderStyle.SHADOW;
                txtInits.push(init);
                add(init);

                m.x = (FlxG.width / 2) - ((m.width + (9 * 3)) / 2);
                txtInits[0].x = m.x + m.width + 4;
                txtInits[1].x = txtInits[0].x + 9;
                txtInits[2].x = txtInits[1].x + 9;

                cursor = new FlxBitmapText(font);
                cursor.alignment = FlxTextAlign.CENTER;
                cursor.y = txtInits[0].y + txtInits[0].height;
                cursor.autoSize = false;
                cursor.fieldWidth = 5;
                cursor.text = "^";
                cursor.visible = false;
                cursor.borderColor = 0xff111111;
                cursor.borderSize = 1;
                cursor.borderStyle = FlxTextBorderStyle.SHADOW;
                cursor.x = txtInits[sel].x;
                add(cursor);
            });
        }
    }

    public function updateInits():Void
    {
        txtInits[0].text = letters[initVals[0]];
        txtInits[1].text = letters[initVals[1]];
        txtInits[2].text = letters[initVals[2]];
    }

    public function updateCursor():Void
    {
        cursor.x = txtInits[sel].x;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (ready)
        {
            cursor.visible = true;

            if (FlxG.keys.anyJustPressed([DOWN, S]))
            {
                initVals[sel] = FlxMath.wrap(initVals[sel] + 1, 0, letters.length - 1);
                updateInits();
                Sounds.play("click", .2);
            }
            else if (FlxG.keys.anyJustPressed([UP, W]))
            {
                initVals[sel] = FlxMath.wrap(initVals[sel] - 1, 0, letters.length - 1);
                updateInits();
                Sounds.play("click", .2);
            }
            else if (FlxG.keys.anyJustPressed([RIGHT, D]))
            {
                sel = FlxMath.wrap(sel + 1, 0, 2);
                updateCursor();
                Sounds.play("swap", .2);
            }
            else if (FlxG.keys.anyJustPressed([LEFT, A]))
            {
                sel = FlxMath.wrap(sel - 1, 0, 2);
                updateCursor();
                Sounds.play("swap", .2);
            }
            else if (FlxG.keys.anyJustPressed([X, SPACE, ENTER]))
            {
                if (sel < 2)
                {
                    sel = FlxMath.wrap(sel + 1, 0, 2);
                    updateCursor();
                    Sounds.play("swap", .2);
                }
                else
                {
                    Sounds.play("match", .5);
                    cursor.visible = false;
                    // send score, get latest scores, show hi scores
                    ready = false;
                    Globals.Save.data.init = letters[initVals[0]] + letters[initVals[1]] + letters[initVals[2]];
                    Globals.Save.flush();

#if ng
                    NGAPI.submitScore(score);
#end

                    AxolAPI.sendScore(score, letters[initVals[0]] + letters[initVals[1]] + letters[initVals[2]], scoreSent);
                }
            }
        }
    }

    public function scoreSent(Msg:Object):Void
    {
        scoresGot(Msg);
    }

    public function scoresGot(Scores:Object):Void
    {
        FlxG.camera.flash(FlxColor.WHITE, .1, function()
        {
            FlxG.switchState(new HiScoreState(Scores, letters[initVals[0]] + letters[initVals[1]] + letters[initVals[2]], score));
        });
    }

    override public function create():Void
    {
        super.create();

        ready = false;

        back.alpha = 0;
        scene.alpha = 0;
        frame.alpha = 0;

        for (k in Counts.counts.keys())
        {
            stats.push(StringTools.replace(k, "_", " ") + ": " + Std.string(Counts.counts.get(k)));
        }
        stats.push("Final Score: " + Std.string(score));

        FlxG.camera.flash(FlxColor.WHITE, .1, function()
        {
            FlxTween.tween(back, {alpha: 1}, .2, {
                type: FlxTweenType.ONESHOT,
                ease: FlxEase.sineIn,
                onComplete: function(_)
                {
                    FlxTween.tween(frame, {alpha: 1}, .2, {
                        type: FlxTweenType.ONESHOT,
                        ease: FlxEase.sineIn,
                        startDelay: .2,
                        onComplete: function(_)
                        {
                            new FlxTimer().start(.66, showStat);

                            FlxTween.tween(scene, {alpha: 1}, .2, {
                                type: FlxTweenType.ONESHOT,
                                ease: FlxEase.sineOut,
                                startDelay: .2,
                                onComplete: function(_)
                                {
                                    new FlxTimer().start(.66, advanceText);

                                    scene.animation.play("play");
                                    scene.animation.finishCallback = function(Anim:String)
                                    {
                                        /*FlxTween.tween(buttonQuit, {alpha:1}, .2, {type:FlxTweenType.ONESHOT, ease:FlxEase.sineOut});
                                            FlxTween.tween(buttonReplay, {alpha:1}, .2, {type:FlxTweenType.ONESHOT, ease:FlxEase.sineOut, onComplete:function(_)
                                            { */
                                        ready = true;
                                        /*}
                                        });*/
                                    };
                                }
                            });
                        }
                    });
                }
            });
        });

        super.create();
    }
}
