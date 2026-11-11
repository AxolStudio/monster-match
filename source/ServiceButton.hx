import flixel.ui.FlxSpriteButton;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.Assets;

/** Original button bevels and state colors, with a reusable bitmap-font label. */
class ServiceButton extends FlxSpriteButton {
    public function new(x:Float, y:Float, width:Int, text:String, action:Void->Void) {
        var label = new PixelBitmapText(FlxBitmapFont.fromAngelCode("assets/images/simple_font.png", "assets/images/simple_font.xml"));
        label.text = text;
        label.color = FlxColor.WHITE;
        label.borderStyle = flixel.text.FlxText.FlxTextBorderStyle.SHADOW;
        label.borderColor = 0xff111111;
        label.borderSize = 1;
        super(x, y, label, action);
        var original = Assets.getBitmapData("assets/images/credits_button.png");
        var strip = new BitmapData(width, 36, true, 0);
        // Keep the original two-pixel end caps; repeat a text-free inner column.
        strip.copyPixels(original, new Rectangle(0, 0, 2, 36), new Point());
        strip.copyPixels(original, new Rectangle(original.width - 2, 0, 2, 36), new Point(width - 2, 0));
        for (column in 2...width - 2)
            strip.copyPixels(original, new Rectangle(1, 0, 1, 36), new Point(column, 0));
        loadGraphic(strip, true, width, 12);
        labelOffsets[0].set(Math.floor((width - label.width) / 2), 2);
        labelOffsets[1].copyFrom(labelOffsets[0]);
        labelOffsets[2].set(labelOffsets[0].x, 3);
        labelAlphas = [1, 1, 1, 0.3];
    }
}
