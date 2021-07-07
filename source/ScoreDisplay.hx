package;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;

class ScoreDisplay extends FlxBitmapText
{
    private var showAmount:Int = 0;

    public function new()
    {
        super(FlxBitmapFont.fromAngelCode(AssetPaths.large_numbers__png, AssetPaths.large_numbers__xml));
        autoSize = false;
        fieldWidth = 56;
        alignment = FlxTextAlign.RIGHT;
        color = FlxColor.ORANGE;
    }

    public function changeAmount(Amount:Int):Void
    {
        showAmount = Amount;
    }

    override public function update(elapsed:Float):Void
    {
        var shownValue:Int = Std.parseInt(text);
        if (shownValue < showAmount)
        {
            if (showAmount >= shownValue + 1000000)
                shownValue += 1000000;
            else if (showAmount >= shownValue + 100000)
                shownValue += 100000;
            else if (showAmount >= shownValue + 10000)
                shownValue += 10000;
            else if (showAmount >= shownValue + 1000)
                shownValue += 1000;
            else if (showAmount >= shownValue + 100)
                shownValue += 100;
            else if (showAmount >= shownValue + 10)
                shownValue += 10;
            else if (showAmount >= shownValue + 1)
                shownValue += 1;
            text = Std.string(shownValue);
        }
        super.update(elapsed);
    }
}
