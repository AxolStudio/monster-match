package;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class HelpState extends FlxState
{
    public var story:FlxSprite;
    public var cauldron:FlxSprite;
    public var tube:Tube;
    public var demo:FlxSprite;
    public var attackMonster:FlxSprite;
    public var attackHero:FlxSprite;
    public var monDamage:AttackAnim;
    public var heroDamage:AttackAnim;
    public var progress:ProgressMeter;
    public var ready:Bool = false;
    public var potions:Array<FlxSprite>;

    public var upButton:FlxSpriteButton;
    public var downButton:FlxSpriteButton;
    public var exitButton:FlxSpriteButton;

    public var scrolling:Bool = false;

    public var forced:Bool = false;

    public function new(?Forced:Bool = false)
    {
        super();
        forced = Forced;
    }

    override public function create():Void
    {
        ready = false;

        story = new FlxSprite(0, 0, GraphicsCache.loadGraphic("assets/images/story.png"));
        add(story);

        cauldron = new FlxSprite();
        cauldron.x = 61;
        cauldron.y = 300;
        cauldron.loadGraphic(GraphicsCache.loadGraphic("assets/images/cauldron.png"), true, 8, 8);
        cauldron.animation.add("burst", [1, 2, 3, 4, 5, 0], 8, true);
        cauldron.animation.play("burst");
        add(cauldron);

        tube = new Tube(78, 349);
        tube.whichMonster = 0;
        add(tube);

        demo = new FlxSprite();
        demo.frames = GraphicsCache.loadGraphicFromAtlas("assets/images/demo.png", "assets/images/demo.xml").atlasFrames;
        demo.animation.addByPrefix("demo", "demo_frame_", 8, true);
        demo.animation.play("demo");
        demo.x = 17;
        demo.y = 351;
        add(demo);

        attackMonster = new FlxSprite();
        attackMonster.loadGraphic(GraphicsCache.loadGraphic("assets/images/monsters.png"), true, 8, 8);
        attackMonster.animation.frameIndex = 8;
        attackMonster.x = 104;
        attackMonster.y = 570;
        add(attackMonster);

        attackHero = new FlxSprite();
        attackHero.loadGraphic(GraphicsCache.loadGraphic("assets/images/heroes.png"), true, 8, 8);
        attackHero.flipX = true;
        attackHero.animation.frameIndex = 1;
        attackHero.x = 112;
        attackHero.y = 570;
        add(attackHero);

        monDamage = new AttackAnim();
        monDamage.x = 104;
        monDamage.y = attackMonster.y;
        add(monDamage);

        heroDamage = new AttackAnim();
        heroDamage.x = 116;
        heroDamage.y = attackMonster.y;
        add(heroDamage);

        progress = new ProgressMeter(74, 1061);
        progress.x = (FlxG.width / 2) - 25;
        add(progress);

        doMonsterTween();
        doHeroTween();

        new FlxTimer().start(1, updateProgress);

        potions = [];
        var p:FlxSprite = new FlxSprite();
        p.loadGraphic(GraphicsCache.loadGraphic("assets/images/monsters.png"), true, 8, 8);
        add(p);
        potions.push(p);

        p = new FlxSprite();
        p.loadGraphic(GraphicsCache.loadGraphic("assets/images/monsters.png"), true, 8, 8);
        add(p);
        potions.push(p);

        p = new FlxSprite();
        p.loadGraphic(GraphicsCache.loadGraphic("assets/images/monsters.png"), true, 8, 8);
        add(p);
        potions.push(p);

        p = new FlxSprite();
        p.loadGraphic(GraphicsCache.loadGraphic("assets/images/monsters.png"), true, 8, 8);
        add(p);
        potions.push(p);

        potions[0].x = 96;
        potions[0].y = 674;
        potions[1].x = 63;
        potions[1].y = 736;
        potions[2].x = 73;
        potions[2].y = 736;
        potions[3].x = 83;
        potions[3].y = 736;

        upButton = new FlxSpriteButton(FlxG.width - 22, FlxG.height - 12, null, clickUp);
        upButton.loadGraphic(GraphicsCache.loadGraphic("assets/images/up_button.png"), true, 8, 8);
        upButton.alpha = .66;
        add(upButton);

        downButton = new FlxSpriteButton(FlxG.width - 12, FlxG.height - 12, null, clickDown);
        downButton.loadGraphic(GraphicsCache.loadGraphic("assets/images/down_button.png"), true, 8, 8);
        downButton.alpha = .66;
        add(downButton);

        exitButton = new FlxSpriteButton(2, 2, null, clickExit);
        exitButton.loadGraphic(GraphicsCache.loadGraphic("assets/images/close_button.png"), true, 8, 8);
        exitButton.alpha = .66;
        add(exitButton);

        FlxG.watch.add(downButton, "alpha", "dB.a");

        FlxG.camera.fade(FlxColor.BLACK, 1, true, function()
        {
            ready = true;
        });

        super.create();
    }

    private function clickUp():Void
    {
        if (!ready)
            return;
        if (FlxG.keys.anyPressed([UP, DOWN, ESCAPE, W, S]))
            return;
        if (scrolling)
            return;

        scrolling = true;
        Sounds.play("click", .2);
        var newDest:Float = FlxMath.bound(story.y + 60, FlxG.height - story.height, 0);
        FlxTween.tween(story, {y: newDest}, .33, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.sineInOut,
            onComplete: function(_)
            {
                scrolling = false;
            }
        });
    }

    private function clickDown():Void
    {
        if (!ready)
            return;
        if (FlxG.keys.anyPressed([UP, DOWN, ESCAPE, W, S]))
            return;
        scrolling = true;
        Sounds.play("click", .2);
        var newDest:Float = FlxMath.bound(story.y - 60, FlxG.height - story.height, 0);
        FlxTween.tween(story, {y: newDest}, .33, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.sineInOut,
            onComplete: function(_)
            {
                scrolling = false;
            }
        });
    }

    private function clickExit():Void
    {
        if (!ready)
            return;
        if (FlxG.keys.anyPressed([UP, DOWN, ESCAPE, W, S]))
            return;
        Sounds.play("click", .2);
        exitScreen();
    }

    private function exitScreen():Void
    {
        ready = false;
        FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
        {
            if (forced)
            {
                Globals.SeenTut = true;
                Globals.Save.data.seenTut = true;
                Globals.Save.flush();
                FlxG.switchState(() ->new PlayState());
            }
            else
                FlxG.switchState(() ->new TitleState());
        });
    }

    private function updateProgress(T:FlxTimer):Void
    {
        progress.progress += .025;
        if (progress.progress >= 1)
            progress.progress = 0;
        T.start(1, updateProgress);
    }

    private function doMonsterTween():Void
    {
        FlxTween.tween(attackMonster, {x: 108}, .5, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.backIn,
            startDelay: .5,
            onComplete: function(_)
            {
                switch (FlxG.random.int(0, 3))
                {
                    case 0:
                        monDamage.playEffect("physblock");
                    case 1:
                        monDamage.playEffect("physhit");
                    case 2:
                        monDamage.playEffect("magblock");
                    case 3:
                        monDamage.playEffect("maghit");
                }

                FlxTween.tween(attackMonster, {x: 104}, .5, {
                    type: FlxTweenType.ONESHOT,
                    ease: FlxEase.backOut,
                    onComplete: function(_)
                    {
                        doMonsterTween();
                    }
                });
            }
        });
    }

    private function doHeroTween():Void
    {
        FlxTween.tween(attackHero, {x: 112}, .5, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.backIn,
            startDelay: .5,
            onComplete: function(_)
            {
                switch (FlxG.random.int(0, 3))
                {
                    case 0:
                        heroDamage.playEffect("physblock");
                    case 1:
                        heroDamage.playEffect("physhit");
                    case 2:
                        heroDamage.playEffect("magblock");
                    case 3:
                        heroDamage.playEffect("maghit");
                }

                FlxTween.tween(attackHero, {x: 116}, .5, {
                    type: FlxTweenType.ONESHOT,
                    ease: FlxEase.backOut,
                    onComplete: function(_)
                    {
                        doHeroTween();
                    }
                });
            }
        });
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (ready)
        {
            upButton.alpha = downButton.alpha = exitButton.alpha = .66;
            if (FlxG.keys.anyPressed([DOWN, S]))
            {
                story.y -= 2;
                if (story.y < FlxG.height - story.height)
                    story.y = FlxG.height - story.height;
            }
            else if (FlxG.keys.anyPressed([UP, W]))
            {
                story.y += 2;
                if (story.y > 0)
                    story.y = 0;
            }
            else if (FlxG.keys.anyPressed([ESCAPE]))
            {
                exitScreen();
            }
            else if (FlxG.mouse.overlaps(upButton))
            {
                upButton.alpha = 1;
            }
            else if (FlxG.mouse.overlaps(downButton))
            {
                downButton.alpha = 1;
            }
            else if (FlxG.mouse.overlaps(exitButton))
            {
                exitButton.alpha = 1;
            }
        }

        tube.fillAmount += .25 * elapsed;
        if (tube.fillAmount >= 1)
        {
            tube.fillAmount -= 1;
            tube.showSpawn();
        }

        updatePos();
    }

    private function updatePos():Void
    {
        cauldron.y = story.y + 300;
        tube.y = story.y + 349;
        demo.y = story.y + 351;
        heroDamage.y = monDamage.y = attackHero.y = attackMonster.y = story.y + 570;
        progress.y = story.y + 1061;

        for (p in potions)
        {
            p.animation.frameIndex = Std.int(40 + ((FlxG.game.ticks / 250) % 7));
        }

        potions[0].y = story.y + 674;

        potions[3].y = potions[2].y = potions[1].y = story.y + 736;
    }
}
