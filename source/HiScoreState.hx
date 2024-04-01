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
import flixel.util.FlxColor;
import openfl.utils.Object;

class HiScoreState extends FlxSubState
{
    public var messages:Array<FlxBitmapText>;
    public var font:FlxBitmapFont;
    public var ready:Bool = false;
    public var frame:FlxSprite;

    public var buttonReplay:FlxSpriteButton;
    public var buttonQuit:FlxSpriteButton;

    public function new(Scores:Object, ?Initials:String = "$", ?Amount:Int = -1)
    {
        super(FlxColor.TRANSPARENT);
        ready = false;
        messages = [];
        font = FlxBitmapFont.fromAngelCode(GraphicsCache.loadGraphic("assets/images/simple_font.png"), "assets/images/simple_font.xml");

        frame = new FlxSprite(0, 0, "assets/images/screen_frame.png");
        frame.screenCenter(FlxAxes.XY);
        frame.alpha = 0;
        add(frame);

        addLine("Hi Scores");
        addLine("");

        var scores:Array<Object> = Scores.data.scores.scores;
        for (s in scores)
        {
            addLine(StringTools.rpad(s.initials + " ", ".", 20) + " " +
                StringTools.lpad(s.amount, "0", 6), s.initials == Initials && Std.parseInt(s.amount) == Amount);
        }

        buttonReplay = new FlxSpriteButton(0, 0, null, closeReplay);
        buttonReplay.loadGraphic(GraphicsCache.loadGraphic("assets/images/replay_button.png"), true, 36, 12);
        buttonReplay.x = frame.x + 2;
        buttonReplay.y = frame.y + frame.height - 2 - buttonReplay.height;

        buttonQuit = new FlxSpriteButton(0, 0, null, closeQuit);
        buttonQuit.loadGraphic(GraphicsCache.loadGraphic("assets/images/exit_button.png"), true, 36, 12);
        buttonQuit.x = frame.x + frame.width - 2 - buttonQuit.width;
        buttonQuit.y = frame.y + frame.height - 2 - buttonQuit.height;

        buttonQuit.alpha = buttonReplay.alpha = 0;

        add(buttonReplay);
        add(buttonQuit);
    }

    private function closeReplay():Void
    {
        if (!ready)
            return;
        ready = false;
        Sounds.play("click", .2);
        FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
        {
            FlxG.switchState(new PlayState());
        });
    }

    private function closeQuit():Void
    {
        if (!ready)
            return;
        ready = false;
        Sounds.play("click", .2);
        FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
        {
            FlxG.switchState(new TitleState());
        });
    }

    override public function create():Void
    {
        FlxTween.tween(frame, {alpha: 1}, .2, {type: FlxTweenType.ONESHOT, ease: FlxEase.circOut});

        var m:FlxBitmapText = null;
        for (i in 0...messages.length)
        {
            m = messages[i];

            FlxTween.tween(m, {alpha: 1}, .2, {type: FlxTweenType.ONESHOT, ease: FlxEase.circOut, startDelay: i * .2});
        }

        FlxTween.num(0, 1, .2, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.circOut,
            startDelay: messages.length * .2,
            onComplete: function(_)
            {
                ready = true;
            }
        }, function(Value:Float)
        {
            buttonQuit.alpha = buttonReplay.alpha = Value;
        });

        super.create();
    }

    private function addLine(Text:String, ?Rainbow:Bool = false):Void
    {
        var t:FlxBitmapText;
        if (Rainbow)
        {
            t = new RainbowText(font);
        }
        else
        {
            t = new FlxBitmapText(font);
        }

        t.text = Text;
        t.alignment = FlxTextAlign.CENTER;
        t.borderStyle = FlxTextBorderStyle.SHADOW;
        t.borderColor = 0xff333333;
        t.borderSize = 1;
        t.y = 8 + (messages.length * 8);
        t.screenCenter(FlxAxes.X);
        t.alpha = 0;
        messages.push(t);
        add(t);
    }
}
