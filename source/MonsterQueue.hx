package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;

class MonsterQueue extends FlxSprite
{
    public var parent:PlayState;

    public function new(Parent:PlayState)
    {
        super();

        parent = Parent;

        makeGraphic(60, 2, FlxColor.TRANSPARENT, true, "mqueue");
    }

    override public function update(elapsed:Float):Void
    {
        pixels.fillRect(pixels.rect, FlxColor.TRANSPARENT);
        var pX:Int = 0;
        // var pY:Int = 0;
        var d:MonsterData = null;
        var r:Rectangle;
        r = new Rectangle(0, 0, 2, 2);
        for (m in parent.monsterQueue)
        {
            if (pX >= 20)
            {
                break;
            }

            d = MonsterData.getFromID(m);
            r.x = pX * 3;
            pixels.fillRect(r, FlxColor.fromString("#" + d.color));
            pX++;
        }

        dirty = true;

        super.update(elapsed);
    }
}
