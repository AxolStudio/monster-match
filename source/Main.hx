package;

import axollib.AxolAPI;
import axollib.AxolversaryState;
// import axollib.DissolveState;
import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.Assets;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;

// hxcpp 4.3's non-ARM64 Android compatibility code still uses `register`.
// Keep the modern compiler diagnostic compatibility scoped to that runtime group.
#if android
@:buildXml('<files id="runtime"><compilerflag value="-Wno-register" /></files>')
#end
class Main extends Sprite
{
    private var wallpaper:Shape;
    private var brickTile:BitmapData;

    public function new()
    {
        super();

        #if !desktop
        AxolAPI.firstState = TitleState;
        AxolAPI.init = Globals.initGame;
        #end
        
        wallpaper = new Shape();
        addChild(wallpaper);
        #if bitmap_log_regression
        addChild(new FlxGame(160, 120, BitmapLogClearRegressionState, 120, 60, true));
        #elseif counter_regression
        addChild(new FlxGame(160, 120, CounterLayoutRegressionState, 120, 60, true));
        #elseif text_regression
        addChild(new FlxGame(160, 120, BitmapTextRegressionState, 120, 60, true));
        #elseif desktop
        addChild(new FlxGame(160, 120, DesktopBoot, 120, 60, true, true));
        #elseif (android || mobile_intro)
        var introStage = openfl.Lib.current.stage;
        addChild(new FlxGame(Std.int(Math.max(160, introStage.stageWidth)), Std.int(Math.max(120, introStage.stageHeight)), mobileintro.MobileIntroState, 120, 60, true));
        #else
        addChild(new FlxGame(160, 120, AxolversaryState, 120, 60, true));
        #end
        if (stage != null) setupWallpaper();
        else addEventListener(Event.ADDED_TO_STAGE, setupWallpaper);
    }

    private function setupWallpaper(?event:Event):Void
    {
        removeEventListener(Event.ADDED_TO_STAGE, setupWallpaper);
        stage.addEventListener(Event.RESIZE, drawWallpaper);
        brickTile = new BitmapData(10, 10, false);
        brickTile.copyPixels(Assets.getBitmapData("assets/images/background.png"), new Rectangle(0, 0, 10, 10), new Point());
        drawWallpaper();
    }

    private function drawWallpaper(?event:Event):Void
    {
        wallpaper.graphics.clear();
        var zoom = Math.max(1, Math.floor(Math.min(stage.stageWidth / 160, stage.stageHeight / 120)));
        wallpaper.graphics.beginBitmapFill(brickTile, new Matrix(zoom, 0, 0, zoom), true, false);
        wallpaper.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        wallpaper.graphics.endFill();
    }
}
