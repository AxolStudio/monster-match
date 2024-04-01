package;


import flixel.FlxSprite;

class AttackAnim extends FlxSprite
{
    public function new()
    {
        super();

        loadGraphic(GraphicsCache.loadGraphic("assets/images/combat_effects.png"), true, 8, 8);
        animation.add("physhit", [2, 1, 0, 0], 12, false);
        animation.add("maghit", [5, 4, 3, 3], 12, false);
        animation.add("physblock", [6, 7, 6, 7], 12, false);
        animation.add("magblock", [8, 9, 10, 11], 12, false);

        visible = false;
    }

    public function playEffect(Effect:String):Void
    {
        visible = true;
        animation.play(Effect, true);
    }

    override public function update(elapsed:Float):Void
    {
        visible = !animation.finished;

        super.update(elapsed);
    }
}
