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

class PauseScreen extends FlxSubState
{
    private var back:FlxSprite;

    private var infos:Array<MonsterInfo>;

    public var ready:Bool = false;

    private var key:FlxBitmapText;

    private var unpause:FlxSpriteButton;
    private var quit:FlxSpriteButton;

    private var text:FlxBitmapText;

    public function new(CurrentEnv:Int, Callback:Void->Void)
    {
        super();

        closeCallback = Callback;

        ready = false;

        back = new FlxSprite();
        back.makeGraphic(FlxG.width, FlxG.height, 0xaa000000);
        back.alpha = 0;

        add(back);

        var mI:MonsterInfo;
        infos = [];

        var envDef:EnvData = EnvData.getFromID(CurrentEnv);
        for (no in 0...envDef.monsters.length)
        {
            mI = new MonsterInfo((FlxG.width / 2) + (no > 2 ? 2 : -70), 10 + (32 * (no % 3)), envDef.monsters[no]);
            mI.alpha = 0;
            add(mI);
            infos.push(mI);
        }

        key = new FlxBitmapText(FlxBitmapFont.fromAngelCode(GraphicsCache.loadGraphic("assets/images/simple_font.png"), "assets/images/simple_font.xml"));
        key.borderStyle = FlxTextBorderStyle.SHADOW;
        key.borderColor = 0xff111111;
        key.borderSize = 1;
        key.text = "H=HP, â=PhysAtt, é=SpAtt,\nP=Def, S=SpDef";
        key.multiLine = true;
        key.alignment = FlxTextAlign.CENTER;
        key.screenCenter(FlxAxes.X);
        key.y = FlxG.height - key.height - 2;
        key.alpha = 0;
        add(key);

        unpause = new FlxSpriteButton(FlxG.width - 12, FlxG.height - 14, null, resumeGame);
        unpause.loadGraphic(GraphicsCache.loadGraphic("assets/images/pause_button.png"), true, 10, 12);
        unpause.alpha = 0;
        add(unpause);

        text = new FlxBitmapText(FlxBitmapFont.fromAngelCode(GraphicsCache.loadGraphic("assets/images/fancy_font.png"), "assets/images/fancy_font.xml"));
        text.borderStyle = FlxTextBorderStyle.SHADOW;
        text.borderColor = 0xff111111;
        text.borderSize = 1;
        text.text = "~ GAME PAUSED ~";
        text.alpha = 0;
        text.y = 2;
        text.screenCenter(FlxAxes.X);
        add(text);

        quit = new FlxSpriteButton(2, 2, null, quitGame);
        quit.loadGraphic(GraphicsCache.loadGraphic("assets/images/quit_button.png"), true, 10, 12);
        quit.alpha = 0;
        add(quit);
    }

    private function quitGame():Void
    {
        // popup ask confirm
        Sounds.play("click", .2);
        openSubState(new ConfirmQuit());
    }

    override public function create():Void
    {
        super.create();

        FlxTween.num(0, 1, .2, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.circOut,
            onComplete: function(_)
            {
                ready = true;
            }
        }, function(Value:Float)
        {
            for (m in infos)
                m.alpha = Value;
            quit.alpha = text.alpha = unpause.alpha = back.alpha = key.alpha = Value;
        });
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (!ready)
            return;
        if (FlxG.keys.anyJustReleased([ESCAPE, P]))
            resumeGame();
    }

    private function resumeGame():Void
    {
        if (!ready)
            return;
        ready = false;
        Sounds.play("click", .2);
        FlxTween.num(1, 0, .2, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.circOut,
            onComplete: function(_)
            {
                close();
            }
        }, function(Value:Float)
        {
            for (m in infos)
                m.alpha = Value;
            quit.alpha = text.alpha = unpause.alpha = back.alpha = key.alpha = Value;
        });
    }
}
