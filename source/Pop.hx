package;

import flixel.FlxSprite;

class Pop extends FlxSprite
{
    public function new()
    {
        super();

        loadGraphic(GraphicsCache.loadGraphic("assets/images/pop.png"), true, 8, 8);
        animation.add("pop", [4, 3, 2, 1, 0], 12, false);
        kill();
    }

    public function start(X:Float, Y:Float):Void
    {
        reset(X, Y);
        animation.play("pop", true);
    }

    override public function update(elapsed:Float):Void
    {
        if (animation.finished)
            kill();

        super.update(elapsed);
    }
}
