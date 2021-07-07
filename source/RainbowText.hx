package;

import flixel.FlxG;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;

class RainbowText extends FlxBitmapText
{
    private var speed:Int = 100;
    private var colors:Array<FlxColor> = [
        FlxColor.RED,
        FlxColor.YELLOW,
        FlxColor.GREEN,
        FlxColor.CYAN,
        FlxColor.BLUE,
        FlxColor.MAGENTA,
        FlxColor.WHITE
    ];

    public function new(?font:FlxBitmapFont, ?Speed:Int = 100)
    {
        super(font);
        speed = Speed;
    }

    override public function draw():Void
    {
        if (alpha > 0 && visible && exists && alive)
            color = colors[Std.int(((FlxG.game.ticks / speed) % 7))];
        super.draw();
    }
}
