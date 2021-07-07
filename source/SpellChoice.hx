package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.effects.particles.FlxEmitter;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class SpellChoice extends FlxSubState
{
    private var back:FlxSprite;
    private var cards:Array<SpellCard>;

    public var ready:Bool = false;

    public var callback:Int->Void;

    public var emitters:Array<FlxEmitter>;

    public var currentHover:Int = -1;

    public function new(Callback:Int->Void)
    {
        super();

        ready = false;

        callback = Callback;

        back = new FlxSprite();
        back.makeGraphic(FlxG.width, FlxG.height, 0x66000000);
        back.alpha = 0;

        add(back);

        cards = [];
        var c:SpellCard = new SpellCard(0);
        cards.push(c);
        c.x = 7;
        c.y = (FlxG.height / 2) - 22;
        c.alpha = 0;

        c = new SpellCard(1);
        cards.push(c);
        c.x = 44 + 14;
        c.y = (FlxG.height / 2) - 22;
        c.alpha = 0;

        c = new SpellCard(2);
        cards.push(c);
        c.x = 44 + 14 + 7 + 44;
        c.y = (FlxG.height / 2) - 22;
        c.alpha = 0;

        var e:FlxEmitter = null;
        emitters = [];
        for (i in 0...3)
        {
            e = new FlxEmitter();
            e.loadParticles(AssetPaths.sparkles__png, 200, 0, true, false);
            e.x = cards[i].x;
            e.y = cards[i].y + cards[i].height - 10;
            e.height = 5;
            e.width = cards[i].width;
            e.launchMode = FlxEmitterMode.SQUARE;
            e.velocity.set(-5, 100, 5, 150, 0, 20, 0, 50);
            e.lifespan.set(.2, 1);
            // e.scale.set(1, 1, .1, .1);
            e.alpha.set(1, 1, 0, 0);
            emitters.push(e);
        }

        add(emitters[0]);
        add(emitters[1]);
        add(emitters[2]);
        add(cards[0]);
        add(cards[1]);
        add(cards[2]);
    }

    override public function create():Void
    {
        ready = false;

        back.alpha = 0;
        for (c in cards)
        {
            c.alpha = 0;
            c.y = (FlxG.height / 2) - 22 + 100;
        }

        FlxG.camera.flash(FlxColor.WHITE, .1, function()
        {
            for (i in 0...3)
            {
                emitters[i].start(false, 0.01);
            }
            FlxTween.tween(back, {alpha: 1}, .2, {
                type: FlxTweenType.ONESHOT,
                ease: FlxEase.sineIn,
                onComplete: function(_)
                {
                    FlxTween.num(0, 1, .33, {
                        ease: FlxEase.backOut,
                        type: FlxTweenType.ONESHOT,
                        onComplete: function(_)
                        {
                            ready = true;
                        }
                    }, function(Value:Float)
                    {
                        for (c in cards)
                        {
                            c.alpha = Value;
                            c.y = (FlxG.height / 2) - 22 + (100 * (1 - Value));
                        }
                    });
                }
            });
        });

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        for (i in 0...3)
        {
            emitters[i].y = cards[i].y + cards[i].height - 10;
        }

        if (ready)
        {
            var over:Int = -1;
            if (FlxG.mouse.overlaps(cards[0]))
            {
                over = 0;
                if (cards[0].y > (FlxG.height / 2) - 27)
                    cards[0].y -= 1;
            }
            else if (FlxG.mouse.overlaps(cards[1]))
            {
                over = 1;
                if (cards[1].y > (FlxG.height / 2) - 27)
                    cards[1].y -= 1;
            }
            else if (FlxG.mouse.overlaps(cards[2]))
            {
                over = 2;
                if (cards[2].y > (FlxG.height / 2) - 27)
                    cards[2].y -= 1;
            }
            if (over != currentHover)
            {
                currentHover = over;
                if (over != -1)
                    Sounds.play("hover_card", .33);
            }

            for (c in cards)
            {
                if (c.whichCard != over)
                {
                    if (c.y < (FlxG.height / 2) - 22)
                        c.y += 1;
                }
            }

            if (over != -1 && FlxG.mouse.justReleased)
            {
                ready = false;
                Sounds.play("spell", .66);
                FlxTween.num(1, 0, .33, {type: FlxTweenType.ONESHOT, ease: FlxEase.backIn}, function(Value:Float)
                {
                    for (c in cards)
                    {
                        if (c.whichCard != over)
                        {
                            c.alpha = Value;
                            c.y = ((FlxG.height / 2) - 22) + (100 * (1 - Value));
                        }
                    }
                    back.alpha = Value;
                });
                FlxTween.tween(cards[over], {alpha: 0, y: -60}, .4, {
                    type: FlxTweenType.ONESHOT,
                    startDelay: .2,
                    onComplete: function(_)
                    {
                        close();
                        callback(over);
                    }
                });
            }
        }

        super.update(elapsed);
    }
}
