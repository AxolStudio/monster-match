package;

import flixel.FlxSprite;

class Transformer extends FlxSprite
{
    public function new(X:Float, Y:Float)
    {
        super(X, Y);

        loadGraphic(GraphicsCache.loadGraphic("assets/images/transform.png"), true, 8, 8);
        animation.add("go", [0, 1, 2], 8, false);

        kill();
    }

    public function start():Void
    {
        revive();
        animation.play("go");
    }

    override public function update(elapsed:Float):Void
    {
        if (animation.finished)
            kill();

        super.update(elapsed);
    }
}
