import flixel.FlxG;
import flixel.FlxState;
import openfl.display.BitmapData;

/** Full intro adds a debug bitmap; its next state switch must safely clear it. */
@:access(flixel.system.debug.log.BitmapLog)
class BitmapLogClearRegressionState extends FlxState {
    override public function create():Void {
        super.create();
        var bitmap = new BitmapData(1, 1, true, 0xFFFFFFFF);
        var result = "PASS";
        try {
            FlxG.bitmapLog.add(bitmap);
            FlxG.bitmapLog.clear();
            #if FLX_DEBUG
            if (FlxG.bitmapLog.window.index >= 0) throw "Cleared log retains a bitmap index";
            #end
        } catch (error:Dynamic) { result = "FAIL: " + Std.string(error); }
        trace(result);
        #if html5
        js.Browser.document.body.setAttribute("data-log-test", result);
        #end
    }
}
