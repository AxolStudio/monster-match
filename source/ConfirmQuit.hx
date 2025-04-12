package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxAxes;

class ConfirmQuit extends FlxSubState
{
    public var quitButton:FlxSpriteButton;
    public var resumeButton:FlxSpriteButton;

    public var quitText:FlxBitmapText;

    public var back:FlxSprite;

    public var ready:Bool = false;

    public function new()
    {
        super();

        ready = false;

        back = new FlxSprite(0, 0, GraphicsCache.loadGraphic("assets/images/prompt_back.png"));
        back.screenCenter(FlxAxes.XY);
        back.alpha = 0;
        add(back);

        quitText = new FlxBitmapText(FlxBitmapFont.fromAngelCode(GraphicsCache.loadGraphic("assets/images/simple_font.png"), "assets/images/simple_font.xml"));
        quitText.text = "Do you really\nwant to quit?";
        quitText.alignment = FlxTextAlign.CENTER;
        quitText.multiLine = true;
        quitText.borderStyle = FlxTextBorderStyle.SHADOW;
        quitText.borderColor = 0xff111111;
        quitText.borderSize = 1;
        quitText.alpha = 0;
        quitText.y = (FlxG.height / 2) - 12;
        quitText.screenCenter(FlxAxes.X);
        add(quitText);

        quitButton = new FlxSpriteButton(0, 0, null, clickQuit);
        quitButton.loadGraphic(GraphicsCache.loadGraphic("assets/images/exit_button.png"), true, 36, 12);
        quitButton.x = (FlxG.width / 2) - 40;
        quitButton.y = (FlxG.height / 2) + 4;
        quitButton.alpha = 0;
        add(quitButton);

        resumeButton = new FlxSpriteButton(0, 0, null, clickResume);
        resumeButton.loadGraphic(GraphicsCache.loadGraphic("assets/images/resume_button.png"), true, 36, 12);
        resumeButton.x = (FlxG.width / 2) + 4;
        resumeButton.y = (FlxG.height / 2) + 4;
        resumeButton.alpha = 0;
        add(resumeButton);

        // trace(quitText.x, quitText.y, quitText.width, quitText.height, (quitButton.width + 4) * 2, quitText.height + quitButton.height);
    }

    override public function create():Void
    {
        FlxTween.num(0, 1, .33, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.circOut,
            onComplete: function(_)
            {
                ready = true;
            }
        }, function(Value:Float)
        {
            back.alpha = quitButton.alpha = resumeButton.alpha = quitText.alpha = Value;
        });
        super.create();
    }

    private function clickQuit():Void
    {
        if (!ready)
            return;
        ready = false;
        Sounds.play("click", .2);
        FlxTween.num(1, 0, .33, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.circIn,
            onComplete: function(_)
            {
                FlxG.switchState(() -> new TitleState());
            }
        }, function(Value:Float)
        {
            back.alpha = quitButton.alpha = resumeButton.alpha = quitText.alpha = Value;
        });
    }

    private function clickResume():Void
    {
        if (!ready)
            return;
        ready = false;
        Sounds.play("click", .2);
        FlxTween.num(1, 0, .33, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.circIn,
            onComplete: function(_)
            {
                close();
            }
        }, function(Value:Float)
        {
            back.alpha = quitButton.alpha = resumeButton.alpha = quitText.alpha = Value;
        });
    }
}
