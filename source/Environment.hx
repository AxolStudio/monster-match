package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;

class Environment extends FlxSprite
{
    public var master:FlxGraphic;
    public var cam:Rectangle;

    public var progress(default, set):Float = 0;

    public var whichEnv(default, null):Int = 0;

    public function new(?X:Float = 0, ?Y:Float = 0, WhichEnv:Int = 0)
    {
        super(X, Y);

        whichEnv = WhichEnv;

        makeGraphic(60, 16, FlxColor.BLACK, true, "environment");

        master = FlxG.bitmap.add(GraphicsCache.loadGraphic("assets/images/environments.png"));

        cam = new Rectangle(master.width - 60, 16 * WhichEnv, 60, 16);
    }

    private function set_progress(Value:Float):Float
    {
        progress = FlxMath.bound(Value, 0, 1);

        if (cam != null && master != null)
        {
            if (progress == 0)
            {
                cam.x = master.width - 60;
            }
            else
            {
                FlxTween.tween(cam, {x: FlxMath.lerp(master.width - 60, 0, progress)}, .66, {type: FlxTweenType.ONESHOT, ease: FlxEase.backInOut});
            }
        }

        return progress;
    }

    override public function draw():Void
    {
        if (master != null && cam != null)
        {
            // var tmp:Rectangle = new Rectangle(Std.int(cam.x), Std.int(cam.y), 60, 0);
            pixels.copyPixels(master.bitmap, cam, _flashPointZero);
        }

        super.draw();
    }
}
