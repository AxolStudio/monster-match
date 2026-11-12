package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxBitmapFont;
import PixelBitmapText as FlxBitmapText;
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
    #if desktop
    var desktopFocus=new DesktopFocus(2,0);
    var onlineToken:String;
    var onlineWait=0.0;
    var localSaved=true;
    #end
    public var messages:Array<FlxBitmapText>;
    public var font:FlxBitmapFont;
    public var ready:Bool = false;
    public var frame:FlxSprite;

    public var buttonReplay:FlxSpriteButton;
    public var buttonQuit:FlxSpriteButton;
    #if android
    private var buttonFriends:ServiceButton;
    #end

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

        #if android
        addLine("Local Hi Scores");
        #elseif desktop
        addLine("Local Hi Scores");
        #else
        addLine("Hi Scores");
        #end
        #if desktop
        onlineToken=Reflect.field(Scores,"desktopOnlineToken");
        localSaved=Reflect.field(Scores,"desktopLocalSaved")!=false;
        addLine(!localSaved?"Local save failed":Reflect.field(Scores,"desktopOnlinePending")==true?"Online: Pending":"Online: Unavailable");
        #else
        addLine("");
        #end

        var scores:Array<Object> = Scores.data.scores.scores;
        for (s in scores)
        {
            addLine(StringTools.rpad(Std.string(s.initials) + " ", ".", 20) + " " +
                StringTools.lpad(Std.string(s.amount), "0", 6), Std.string(s.initials) == Initials && Std.parseInt(Std.string(s.amount)) == Amount);
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
        #if android
        buttonFriends = new ServiceButton(54, buttonQuit.y, 52, "FRIENDS", function() {
            if (ready) PlayServices.friends();
        });
        buttonFriends.alpha = 0;
        add(buttonFriends);
        #end
    }

    private function closeReplay():Void
    {
        if (!ready)
            return;
        ready = false;
        PlayServices.cancelUi();
        Sounds.play("click", .2);
        FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
        {
            FlxG.switchState(() -> new PlayState());
        });
    }

    private function closeQuit():Void
    {
        if (!ready)
            return;
        ready = false;
        PlayServices.cancelUi();
        Sounds.play("click", .2);
        FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
        {
            FlxG.switchState(() -> new TitleState());
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
            #if android
            buttonFriends.alpha = Value;
            #end
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
    #if desktop
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if(onlineToken!=null){
            onlineWait+=elapsed;
            var result=DesktopOnline.takeResult(onlineToken);
            if(result!=null || onlineWait>=10){
                var sent=result!=null && result.status=="ok";
                messages[1].text=localSaved?(sent?"Online: Sent":"Online: Unavailable"):(sent?"Sent; local save failed":"Local save failed");
                messages[1].screenCenter(FlxAxes.X);
                onlineToken=null;
            }
        }
        if(!ready||subState!=null)return;
        var frame=DesktopInput.sample(elapsed);
        var accept=desktopFocus.update(frame);
        desktopFocus.paint([buttonReplay,buttonQuit]);
        if(desktopFocus.armed&&frame.back){closeQuit();return;}
        if(accept){if(desktopFocus.index==0)closeReplay();else closeQuit();}
    }
    #end
}
