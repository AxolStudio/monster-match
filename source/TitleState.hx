package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class TitleState extends FlxState
{
    public var buttonPlay:FlxSpriteButton;
    public var buttonHelp:FlxSpriteButton;
    public var buttonCredits:FlxSpriteButton;

    public var title:FlxSprite;
    public var logoEffect:FlxEffectSprite;
    public var logo:FlxSprite;

    public var titleEffect:FlxEffectSprite;
    public var titleWave:FlxWaveEffect;

    public var logoWave:FlxWaveEffect;

    public var ready:Bool = false;

    override public function create():Void
    {
        // Globals.initGame();

        Sounds.playMusic("title");

        title = new FlxSprite();
        title.loadGraphic(GraphicsCache.loadGraphic("assets/images/title.png"));
        title.screenCenter(FlxAxes.X);
        title.y = FlxG.height - title.height;
        // add(title);

        titleWave = new FlxWaveEffect(FlxWaveMode.END, 20, 0, 5, 5, FlxWaveDirection.HORIZONTAL, 1);

        titleEffect = new FlxEffectSprite(title, [titleWave]);
        titleEffect.x = title.x;
        titleEffect.y = title.y;
        add(titleEffect);

        logo = new FlxSprite();
        logo.loadGraphic(GraphicsCache.loadGraphic("assets/images/title_logo.png"));
        logo.screenCenter(FlxAxes.X);
        logo.x = Std.int(logo.x);
        logo.y = 2;
        logo.alpha = 0;
        // add(logo);

        logoWave = new FlxWaveEffect(FlxWaveMode.ALL, 10, 0.5, 3, 2, FlxWaveDirection.VERTICAL, 0);
        logoEffect = new FlxEffectSprite(logo, [logoWave]);
        logoEffect.x = logo.x;
        logoEffect.y = logo.y;
        add(logoEffect);

        buttonPlay = new FlxSpriteButton(0, 0, null, clickPlay); // (0, 0, "PLAY", clickPlay);
        buttonPlay.loadGraphic(GraphicsCache.loadGraphic("assets/images/play_button.png"), true, 24, 12);
        buttonPlay.x = 2;
        buttonPlay.y = FlxG.height - 14;
        buttonPlay.alpha = 0;
        add(buttonPlay);

        buttonHelp = new FlxSpriteButton(0, 0, null, clickHelp); // 0, 0, "HOW TO", clickHelp);
        buttonHelp.loadGraphic(GraphicsCache.loadGraphic("assets/images/tut_button.png"), true, 10, 12);
        buttonHelp.x = buttonPlay.x + buttonPlay.width + 2;
        buttonHelp.y = FlxG.height - 14;
        buttonHelp.alpha = 0;
        add(buttonHelp);

        buttonCredits = new FlxSpriteButton(0, 0, null, clickCredits); // 0, 0, "CREDITS", clickCredits);
        buttonCredits.loadGraphic(GraphicsCache.loadGraphic("assets/images/credits_button.png"), true, 37, 12);
        buttonCredits.x = FlxG.width - buttonCredits.width - 2;
        buttonCredits.y = FlxG.height - 14;
        buttonCredits.alpha = 0;
        add(buttonCredits);

        FlxG.camera.fade(FlxColor.BLACK, 1, true);
        FlxTween.num(0, 1, 1, {type: FlxTweenType.ONESHOT, ease: FlxEase.sineIn, startDelay: .2}, function(Value:Float)
        {
            titleWave.center = Value;
        });
        FlxTween.num(0, 1, 1, {type: FlxTweenType.ONESHOT, ease: FlxEase.sineIn, startDelay: .4}, function(Value:Float)
        {
            titleWave.strength = Math.round(FlxMath.lerp(20, 0, Value));
        });
        FlxTween.tween(titleEffect, {y: -3}, 2, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.sineInOut,
            onComplete: function(_)
            {
                FlxG.camera.flash(0x66ffff00, .2, function()
                {
                    Sounds.play("thunder_01", .33);
                    FlxG.camera.flash(0x33ffff00, .2);
                });
                FlxTween.num(0, 1, 1, {
                    type: FlxTweenType.ONESHOT,
                    ease: FlxEase.sineIn,
                    startDelay: .2,
                    onComplete: function(_)
                    {
                        Sounds.play("thunder_02", .5);
                        FlxG.camera.flash(0x99ffff00, .4);
                        FlxTween.num(0, 1, .33, {
                            type: FlxTweenType.ONESHOT,
                            ease: FlxEase.sineOut,
                            onComplete: function(_)
                            {
                                ready = true;
                                FlxG.mouse.visible = true;
                            }
                        }, function(Value:Float)
                        {
                            buttonCredits.alpha = buttonHelp.alpha = buttonPlay.alpha = Value;
                        });
                    }
                }, function(Value:Float)
                {
                    logoWave.strength = Math.round(FlxMath.lerp(10, 0, Value));
                    // logoWave.wavelength = Math.round(FlxMath.lerp(2, 20, Value));
                    // logoWave.speed = FlxMath.lerp(3, 1, Value);
                });
                FlxTween.tween(logo, {alpha: 1}, .33, {type: FlxTweenType.ONESHOT, ease: FlxEase.sineOut});
            }
        });

        super.create();
    }

    private function clickPlay():Void
    {
        if (!ready)
            return;
        ready = false;
        Sounds.play("click", .2);
        FlxG.camera.flash(0x99ffff00, .2, function()
        {
            FlxG.camera.fade(FlxColor.BLACK, .66, false, function()
            {
                if (!Globals.SeenTut)
                    FlxG.switchState(() -> new HelpState(true));
                else
                    FlxG.switchState(() -> new PlayState());
            });
        });
    }

    private function clickHelp():Void
    {
        if (!ready)
            return;
        ready = false;
        Sounds.play("click", .2);
        FlxG.camera.flash(0x99ffff00, .2, function()
        {
            FlxG.camera.fade(FlxColor.BLACK, .66, false, function()
            {
                FlxG.switchState(() -> new HelpState());
            });
        });
    }

    private function clickCredits():Void
    {
        if (!ready)
            return;
        ready = false;
        Sounds.play("click", .2);
        FlxG.camera.flash(0x99ffff00, .2, function()
        {
            FlxG.camera.fade(FlxColor.BLACK, .66, false, function()
            {
                FlxG.switchState(() -> new CreditsState());
            });
        });
    }
}
