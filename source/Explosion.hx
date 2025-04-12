package;

import axollib.GraphicsCache;
import flixel.FlxSprite;

class Explosion extends FlxSprite
{
    public function new()
    {
        super();

        frames = GraphicsCache.loadGraphicFromAtlas("assets/images/explosion.png", "assets/images/explosion.xml").atlasFrames;

        animation.addByPrefix("explosion", "regularExplosion0", 8, false);
        animation.onFinish.add((_) -> kill());

        kill();
    }

    public function start(X:Float, Y:Float):Void
    {
        reset(X - 11, Y - 11);
        animation.play("explosion");
    }
}
