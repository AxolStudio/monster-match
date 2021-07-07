package;

import flixel.FlxG;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class FloatingNumber extends FlxBitmapText
{
    private var colors:Array<FlxColor> = [
        FlxColor.RED,
        FlxColor.YELLOW,
        FlxColor.GREEN,
        FlxColor.CYAN,
        FlxColor.BLUE,
        FlxColor.MAGENTA,
        FlxColor.WHITE
    ];

    public function new()
    {
        super(FlxBitmapFont.fromAngelCode(AssetPaths.tiny_digits__png, AssetPaths.tiny_digits__xml));

        autoSize = false;
        alignment = FlxTextAlign.CENTER;
        fieldWidth = 16;
        borderStyle = FlxTextBorderStyle.OUTLINE;
        borderSize = 1;
        borderColor = 0xff333333;

        kill();
    }

    public function start(X:Float, Y:Float, Value:String):Void
    {
        reset(X - 4, Y - 6);
        text = Value;
        alpha = 0;

        FlxTween.tween(this, {alpha: 1}, .2, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.circOut,
            onComplete: function(_)
            {
                FlxTween.tween(this, {alpha: 0}, .2, {
                    type: FlxTweenType.ONESHOT,
                    ease: FlxEase.circIn,
                    startDelay: .4,
                    onComplete: function(_)
                    {
                        kill();
                    }
                });
            }
        });

        FlxTween.tween(this, {y: Y - 10}, .8, {type: FlxTweenType.ONESHOT, ease: FlxEase.backIn});
    }

    override public function draw():Void
    {
        if (alpha > 0 && visible && exists && alive)
            color = colors[Std.int(((FlxG.game.ticks / 100) % 7))];
        super.draw();
    }
}
