package;


import flixel.FlxSprite;

class Barrier extends FlxSprite
{

    public function new()
    {
        super();
        loadGraphic(GraphicsCache.loadGraphic("assets/images/barrier.png"), true, 6, 16);
        animation.add("hit", [1, 2, 0], 12, false);
        kill();
    }

    override public function hurt(Damage:Float):Void
    {
        super.hurt(Damage);
        if (alive)
            animation.play("hit");
    }
}
