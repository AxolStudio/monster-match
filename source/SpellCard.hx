package;

import flixel.FlxSprite;
import flixel.addons.display.FlxSliceSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;

class SpellCard extends FlxGroup
{
    public var x(default, set):Float = 0;
    public var y(default, set):Float = 0;
    public var width(default, null):Float = 42;
    public var height(default, null):Float = 42;
    public var alpha(default, set):Float = 1;

    private var back:FlxSliceSprite;
    private var symbol:FlxSprite;

    public var whichCard(default, null):Int = -1;

    public function new(WhichCard:Int = -1)
    {
        super();

        back = new FlxSliceSprite(AssetPaths.spell_back__png, new FlxRect(7, 7, 41, 17), 44, 44);

        whichCard = WhichCard;

        symbol = new FlxSprite();
        switch (whichCard)
        {
            case 0:
                symbol.loadGraphic(AssetPaths.juggler__png);
            case 1:
                symbol.loadGraphic(AssetPaths.injustice__png);
            case 2:
                symbol.loadGraphic(AssetPaths.striking_balls__png);
            default:
        }

        add(back);
        symbol.x = 4;
        symbol.y = 4;
        add(symbol);
    }

    private function set_x(Value:Float):Float
    {
        x = Value;
        back.x = x;
        symbol.x = x + 4;

        return x;
    }

    private function set_y(Value:Float):Float
    {
        y = Value;
        back.y = y;
        symbol.y = y + 4;

        return y;
    }

    public function set_alpha(Value:Float):Float
    {
        alpha = FlxMath.bound(Value, 0, 1);
        back.alpha = symbol.alpha = alpha;
        return alpha;
    }
}
