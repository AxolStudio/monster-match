package;

import flixel.FlxSprite;
import flixel.addons.display.FlxSliceSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class ProgressMeter extends FlxGroup
{
    public var x(default, set):Float = 0;
    public var y(default, set):Float = 0;
    public var back:FlxSliceSprite;
    public var cap:FlxSprite;
    public var party:FlxSprite;
    public var door:FlxSprite;
    public var whichEnv:Int = -1;

    public var progress(default, set):Float;

    public function new(X:Float, Y:Float)
    {
        super();

        x = X;
        y = Y;

        back = new FlxSliceSprite(AssetPaths.progress_back__png, new FlxRect(0, 0, 1, 6), 46, 6);
        back.x = x + 7;
        back.y = y + 2;
        add(back);

        cap = new FlxSprite(AssetPaths.progress_cap__png);
        cap.x = back.x + back.width;
        cap.y = back.y;
        add(cap);

        door = new FlxSprite();
        door.loadGraphic(AssetPaths.door_indicator__png, true, 8, 8);

        door.x = back.x - (door.width / 2);
        door.y = back.y + (back.height / 2) - (door.width / 2);
        add(door);

        party = new FlxSprite();
        party.loadGraphic(AssetPaths.party_indicator__png);
        party.x = back.x + back.width - (party.width / 2);
        party.y = back.y + (back.height / 2) - (party.height / 2);
        add(party);

        progress = 0;
    }

    private function set_progress(Value:Float):Float
    {
        progress = FlxMath.bound(Value, 0, 1);

        if (progress >= .9)
        {
            if (whichEnv < 5)
                door.animation.frameIndex = 1;
            else
                door.animation.frameIndex = 3;
        }
        else
        {
            if (whichEnv < 5)
                door.animation.frameIndex = 0;
            else
                door.animation.frameIndex = 2;
        }

        if (progress == 0)
        {
            party.x = back.x + back.width - (party.width / 2);
            if (party.alpha == 0)
            {
                party.scale.set(.5, .5);
                FlxTween.tween(party, {alpha: 1}, .5, {type: FlxTweenType.ONESHOT, ease: FlxEase.circOut});
                FlxTween.tween(party.scale, {x: 1, y: 1}, .5, {type: FlxTweenType.ONESHOT, ease: FlxEase.circOut});
            }
        }
        else
        {
            FlxTween.tween(party, {x: FlxMath.lerp(back.x + back.width, back.x, progress) - (party.width / 2)}, .2, {
                type: FlxTweenType.ONESHOT,
                ease: FlxEase.circInOut,
                onComplete: function(_)
                {
                    if (progress == 1)
                    {
                        FlxTween.tween(party, {alpha: 0}, .5, {type: FlxTweenType.ONESHOT, ease: FlxEase.circOut});
                        FlxTween.tween(party.scale, {x: 1.5, y: 1.5}, .5, {type: FlxTweenType.ONESHOT, ease: FlxEase.circOut});
                    }
                }
            });
        }

        return progress;
    }

    private function set_x(Value:Float):Float
    {
        x = Value;

        if (back != null && door != null && party != null)
        {
            back.x = x + 7;

            cap.x = back.x + back.width;

            door.x = back.x - (door.width / 2);

            party.x = FlxMath.lerp(x + 53, x + 7, progress) - (party.width / 2);
        }

        return x;
    }

    private function set_y(Value:Float):Float
    {
        y = Value;

        if (back != null && door != null && party != null)
        {
            back.y = y + 2;

            cap.y = back.y;

            door.y = back.y + (back.height / 2) - (door.width / 2);

            party.y = back.y + (back.height / 2) - (party.height / 2);
        }

        return x;
    }
}
