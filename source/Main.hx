package;

import axollib.AxolAPI;
import axollib.DissolveState;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
    public function new()
    {
        super();

        AxolAPI.firstState = TitleState;
        addChild(new FlxGame(160, 120, DissolveState, 1, 120, 30));
    }
}
