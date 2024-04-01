package;

import flixel.FlxG;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class ComboDisplay extends FlxBitmapText
{
    private var tween:FlxTween;
    private var colors:Array<FlxColor> = [
        FlxColor.RED,
        FlxColor.YELLOW,
        FlxColor.GREEN,
        FlxColor.CYAN,
        FlxColor.BLUE,
        FlxColor.MAGENTA,
        FlxColor.WHITE
    ];

    private var baseY:Float;
    private var baseX:Float;

    public function new(X:Float, Y:Float)
    {
        super(FlxBitmapFont.fromAngelCode(GraphicsCache.loadGraphic("assets/images/large_numbers.png"), "assets/images/large_numbers.xml"));

        x = baseX = X;
        y = baseY = Y;

        text = "*1";

        alpha = 0;
    }

    override public function draw():Void
    {
        if (alpha > 0 && visible && exists && alive)
            color = colors[Std.int(((FlxG.game.ticks / 100) % 7))];
        super.draw();
    }

    public function show(Value:Int):Void
    {
        text = "*" + Value;

        if (alpha == 0)
        {
            if (tween != null)
                tween.cancel;
        }

        alpha = 0;
        y = baseY + 4;
        x = baseX - (width / 2);
        tween = FlxTween.tween(this, {alpha: 1, y: baseY}, .2, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.backOut,
            onComplete: function(_)
            {
                tween = FlxTween.tween(this, {alpha: 0, y: baseY - 4}, .2, {type: FlxTweenType.ONESHOT, ease: FlxEase.backIn, startDelay: 1});
            }
        });
    }
}
