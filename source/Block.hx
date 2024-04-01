package;

import flixel.FlxG;
import flixel.FlxSprite;

class Block extends FlxSprite
{
    public var isMatched:Bool = false;
    public var matchedX:Bool = false;
    public var matchedY:Bool = false;
    public var falling(default, set):Bool = false;
    public var shifting(default, set):Bool = false;
    public var baseY:Float = -1;
    public var baseX:Float = -1;
    public var isNew:Bool = false;
    public var isPotion(default, set):Bool = false;
    public var skull(default, set):Bool = false;

    public function new()
    {
        super();
        loadGraphic(GraphicsCache.loadGraphic("assets/images/monsters.png"), true, 8, 8);
    }

    private function set_falling(Value:Bool):Bool
    {
        if (Value)
        {
            baseY = y;
        }
        falling = Value;
        return falling;
    }

    private function set_shifting(Value:Bool):Bool
    {
        if (Value)
        {
            baseX = x;
        }
        shifting = Value;
        return shifting;
    }

    override public function revive():Void
    {
        super.revive();
        isPotion = skull = isMatched = matchedX = matchedY = falling = shifting = false;
        baseY = baseX = -1;
    }

    private function set_isPotion(Value:Bool):Bool
    {
        if (isPotion != Value)
            isPotion = Value;

        if (isPotion)
        {
            skull = false;
            animation.frameIndex = 40;
        }

        return isPotion;
    }

    override public function draw():Void
    {
        if (isPotion)
            animation.frameIndex = Std.int(40 + ((FlxG.game.ticks / 250) % 7));
        super.draw();
    }

    private function set_skull(Value:Bool):Bool
    {
        if (skull != Value)
        {
            skull = Value;
            if (skull)
                animation.frameIndex = 47;
        }
        return skull;
    }
}
