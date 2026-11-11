import flixel.FlxG;
import flixel.FlxBasic;

/** Uses Flixel's camera-aware coordinates, including integer-scale margins. */
class GamePointer {
    public static function pauseReleased():Bool {
        #if android
        if (FlxG.android.justReleased.BACK) return true;
        #end
        return FlxG.keys.anyJustReleased([ESCAPE, P]);
    }

    public static function overlaps(sprite:FlxBasic):Bool {
        #if FLX_TOUCH
        for (touch in FlxG.touches.list)
            if (touch.pressed || touch.justReleased) return touch.overlaps(sprite);
        #end
        return FlxG.mouse.overlaps(sprite);
    }

    public static function releasedOver(sprite:FlxBasic):Bool {
        #if FLX_TOUCH
        for (touch in FlxG.touches.list)
            if (touch.pressed || touch.justReleased) return touch.justReleased && touch.overlaps(sprite);
        #end
        return FlxG.mouse.justReleased && FlxG.mouse.overlaps(sprite);
    }
}
