package;

import flixel.FlxSprite;

class Barrier extends FlxSprite
{
    public var health:Float = 0;

    public function new()
    {
        super();
        loadGraphic(GraphicsCache.loadGraphic("assets/images/barrier.png"), true, 6, 16);
        animation.add("hit", [1, 2, 0], 12, false);
        kill();
    }

    public function hurt(Damange:Float):Void
    {
        if (alive)
        {
            health -= Damange;
            if (health <= 0)
            {
                kill();
            }
            else
                animation.play("hit");
        }
    }
}
