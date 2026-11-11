package;

import axollib.AxolAPI;
import flixel.FlxG;
import flixel.util.FlxSave;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.Lib;

class Globals
{
    #if android
    static public var AXOL_KEY:String = "";
    #else
    static public var AXOL_KEY:String = Keys.keys.get("axolapi");
    #end

    static public var Save:FlxSave;
    static public var gameInitialized:Bool = false;

    static public var SeenTut:Bool = false;
    static private var pointerPresentation = new PointerPresentation();

    static public function initGame():Void
    {
        if (gameInitialized)
            return;
        gameInitialized = true;

        #if !android
        AxolAPI.initialize(AXOL_KEY);
        #end


#if ng
        NGAPI.init();
#end

        Save = new FlxSave();
        Save.bind("MonsterMatch-userData");
        var playerID:String;
        if (Save.data.guid == null || Save.data.guid == "")
            playerID = AxolAPI.generateGUID();
        else
            playerID = Save.data.guid;

        if (Save.data.init == null)
            Save.data.init = "   ";

        if (Save.data.seenTut == null)
            SeenTut = false;
        else
            SeenTut = Save.data.seenTut;

        #if !android
        AxolAPI.initSave(playerID, Save);
        #end
        Counts.init();
        #if android
        GameEvents.initialize();
        #end

        FlxG.autoPause = true;
        #if android
        // Keep Lime from sending the task home before gameplay handles Back.
        FlxG.android.preventDefaultKeys = [BACK];
        #end
        FlxG.scaleMode = new CompactPixelScaleMode();
        FlxG.camera.antialiasing = false;
        GraphicsCache.preloadGraphics();
        FlxG.mouse.load("assets/images/cursor-3x.png", 1, 1, 1);
        mouseOffScreen(null);
        #if FLX_TOUCH
        FlxG.stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchOnScreen);
        FlxG.stage.addEventListener(TouchEvent.TOUCH_MOVE, touchOnScreen);
        FlxG.stage.addEventListener(TouchEvent.TOUCH_END, touchOnScreen);
        #end
        Sounds.preloadSounds();

        MonsterData.initData();
        HeroData.initData();
        EnvData.initData();
    }

    static public function mouseOffScreen(E:Event):Void
    {
        FlxG.mouse.visible = false;
        FlxG.stage.removeEventListener(Event.MOUSE_LEAVE, mouseOffScreen);
        FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseOnScreen);
    }

    static public function mouseOnScreen(E:MouseEvent):Void
    {
        if (!pointerPresentation.mouse(Lib.getTimer())) return;
        FlxG.mouse.visible = true;
        FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseOnScreen);
        FlxG.stage.addEventListener(Event.MOUSE_LEAVE, mouseOffScreen);
    }

    static private function touchOnScreen(E:TouchEvent):Void
    {
        pointerPresentation.touch(Lib.getTimer());
        mouseOffScreen(null);
    }
}
