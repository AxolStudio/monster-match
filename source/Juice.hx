package;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class Juice extends FlxSprite
{
    public function new()
    {
        super();

        loadGraphic(AssetPaths.juice__png, true, 8, 8);
        animation.add("play", [0, 1], 12, true);

        kill();
    }

    public function start(StartX:Float, StartY:Float, Color:String, DestX:Float, DestY:Float):Void
    {
        reset(StartX - 4, StartY - 4);
        animation.play("play");
        color = FlxColor.fromString("#" + Color);
        FlxTween.tween(this, {x: DestX - 4}, .33, {type: FlxTweenType.ONESHOT, ease: FlxEase.backIn});
        FlxTween.tween(this, {y: DestY - 4}, .33, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.circInOut,
            onComplete: function(_)
            {
                kill();
            }
        });
    }
}
