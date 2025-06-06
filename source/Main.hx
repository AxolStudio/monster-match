package;

import axollib.AxolAPI;
import axollib.AxolversaryState;
// import axollib.DissolveState;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
    public function new()
    {
        super();

        AxolAPI.firstState = TitleState;
        AxolAPI.init = Globals.initGame;
        
        addChild(new FlxGame(160, 120, AxolversaryState, 120, 60, true));
    }
}
