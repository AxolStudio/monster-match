package;

import axollib.GraphicsCache;
import flixel.FlxSprite;

class Explosion extends FlxSprite
{
    public function new()
    {
        super();

        frames = GraphicsCache.loadGraphicFromAtlas("explosion", AssetPaths.explosion__png, AssetPaths.explosion__xml).atlasFrames;

        animation.addByPrefix("explosion", "regularExplosion0", 8, false);

        kill();
    }

    public function start(X:Float, Y:Float):Void
    {
        reset(X - 11, Y - 11);
        animation.play("explosion");
        animation.finishCallback = function(Anim:String)
        {
            kill();
        };
    }
}
