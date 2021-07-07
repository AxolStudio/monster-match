package;

import axollib.AxolAPI;
import flixel.FlxG;
import flixel.util.FlxSave;
import openfl.events.Event;
import openfl.events.MouseEvent;

class Globals
{
    static public var AXOL_KEY:String = Keys.keys.get("axolapi");

    static public var Save:FlxSave;
    static public var gameInitialized:Bool = false;

    static public var SeenTut:Bool = false;

    static public function initGame():Void
    {
        if (gameInitialized)
            return;
        gameInitialized = true;

        AxolAPI.initialize(AXOL_KEY);

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

        AxolAPI.initSave(playerID, Save);
        Counts.init();

        FlxG.autoPause = false;
        FlxG.mouse.load(AssetPaths.cursor__png, 3, 1, 1);
        mouseOffScreen(null);
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
        FlxG.mouse.visible = true;
        FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseOnScreen);
        FlxG.stage.addEventListener(Event.MOUSE_LEAVE, mouseOffScreen);
    }
}
