import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import PixelBitmapText as FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;

/** Actual renderer regression, enabled only with -D text_regression. */
@:access(flixel.text.FlxBitmapText)
class BitmapTextRegressionState extends FlxState {
    override public function create():Void {
        super.create();
        Globals.initGame();
        var result = "PASS";
        try {
            var font = FlxBitmapFont.fromAngelCode("assets/images/fancy_font.png", "assets/images/fancy_font.xml");
            var label = new FlxBitmapText(font);
            label.autoSize = false;
            label.fieldWidth = 60;
            label.alignment = FlxTextAlign.CENTER;
            check(label, "Garden");
            label.alignment = FlxTextAlign.RIGHT;
            check(label, "1");
            check(label, "123");
            label.destroy();
        } catch (error:Dynamic) {
            result = "FAIL: " + Std.string(error);
        }
        trace(result);
        #if html5
        js.Browser.document.body.setAttribute("data-text-test", result);
        #end
    }

    private function check(label:FlxBitmapText, value:String):Void {
        label.text = value;
        label.checkPendingChanges(true);
        var data:Array<Float> = cast label.textData;
        var expected = label.font.minOffsetX + (label.alignment == FlxTextAlign.CENTER
            ? Std.int((label.fieldWidth - label.getStringWidth(value)) / 2)
            : label.fieldWidth - label.getStringWidth(value) - label.padding);
        if (data[1] != expected)
            throw value + " alignment: expected " + expected + ", got " + data[1];
    }
}
