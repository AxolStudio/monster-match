package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Meteor extends FlxSprite
{
    public var targetX(default, null):Float = 0;
    public var targetY(default, null):Float = 0;
    public var callback(default, null):Void->Void;

    public function new()
    {
        super();
        loadGraphic(AssetPaths.meteor__png);

        kill();
    }

    public function start(TargetX:Float, TargetY:Float, Delay:Float, ?Callback:Void->Void):Void
    {
        targetX = TargetX;
        targetY = TargetY;

        callback = Callback;

        reset(targetX, targetY - (FlxG.height + 50) - height);
        scale.set(4, 4);
        FlxTween.num(0, 1, 1, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.sineIn,
            startDelay: Delay,
            onComplete: function(_)
            {
                kill();
                if (callback != null)
                    callback();
            }
        }, function(Value:Float)
        {
            scale.set(FlxMath.lerp(4, 1, Value), FlxMath.lerp(4, 1, Value));
            y = targetY - height - FlxMath.lerp(FlxG.height + 50, 0, Value);
        });
        /*FlxTween.tween(this, {y:targetY - height},2,{type:FlxTweenType.ONESHOT, ease:FlxEase.sineIn, onComplete:function(_){
            kill();
            if (callback != null)
                callback();
        }});*/
    }
}
