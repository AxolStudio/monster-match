package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class CreditsState extends FlxState
{

	public var messages:Array<FlxBitmapText>;
	public var messages2:Array<FlxBitmapText>;
	public var font:FlxBitmapFont;
	public var ready:Bool = false;
	public var logo:FlxSprite;
	
	public var buttonQuit:FlxSpriteButton;

	public function new()
	{
		super();
		
		ready = false;
		messages = [];
		messages2 = [];
		font = FlxBitmapFont.fromAngelCode(AssetPaths.simple_font__png, AssetPaths.simple_font__xml);
		
		addLine("Credits");
		addLine("");
		addLine("Design & Code:","Tim I Hely");
		addLine("Music:","Filippo Vicarelli");
		addLine("Title Artwork:", "Mau Mora");
		addLine("Game Art:","Oryx Design Lab");
		addLine("");
		addLine("");
		addLine("");
		addLine("");
		addLine("©2019 Axol Studio, LLC");
		addLine("axolstudio.com");
		
		buttonQuit = new FlxSpriteButton(0, 0, null, closeQuit);//new FlxButton(0, 0, "Replay", closeReplay);
		buttonQuit.loadGraphic(AssetPaths.exit_button__png, true, 36, 12);
		buttonQuit.x =  FlxG.width -  2 - buttonQuit.width;
		buttonQuit.y = FlxG.height - 2 - buttonQuit.height;
		buttonQuit.alpha = 0;
		add(buttonQuit);
		
		
		logo = new FlxSprite(0, messages[5].y + messages[5].height+2, AssetPaths.axol_logo__png);
		logo.alpha = 0;
		logo.screenCenter(FlxAxes.X);
		add(logo);
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
	
	private function addLine(Text:String, ?Text2:String):Void
	{
		
		
		var t:FlxBitmapText;
		
		t = new FlxBitmapText(font);
		t.text = Text;
		
		t.borderStyle = FlxTextBorderStyle.SHADOW;
		t.borderColor = 0xff333333;
		t.borderSize = 1;
		t.y = 4  + (messages.length * 8);
		if (Text2 == null)
		{
			t.alignment = FlxTextAlign.CENTER;
			t.screenCenter(FlxAxes.X);
		}
		else
		{
			t.alignment = FlxTextAlign.RIGHT;
			t.x = (FlxG.width / 2) - t.width - 2;
		}
		
		t.alpha = 0;
		messages.push(t);
		add(t);
		
		if (Text2 != null)
		{
			t = new RainbowText(font, 250);
			t.text = Text2;
			t.borderStyle = FlxTextBorderStyle.SHADOW;
			t.borderColor = 0xff333333;
			t.borderSize = 1;
			t.y = 4  + ((messages.length - 1) * 8);
			t.alignment = FlxTextAlign.LEFT;
			t.x = (FlxG.width / 2) + 2;
			t.alpha = 0;
			messages2[messages.length - 1] = t;
			add(t);
		}
		
	}
	
	override public function create():Void 
	{
		
		
		
		
		for (i in 0...messages.length)
		{
			FlxTween.tween(messages[i], {alpha:1}, .2, {type:FlxTweenType.ONESHOT, ease:FlxEase.circOut, startDelay: i * .2});
			
			if (messages2[i] != null)
			{
				FlxTween.tween(messages2[i], {alpha:1}, .2, {type:FlxTweenType.ONESHOT, ease:FlxEase.circOut, startDelay: i * .2});
			}
		}
		
		FlxTween.tween(logo, {alpha:1}, .2, {type:FlxTweenType.ONESHOT, ease:FlxEase.circOut, startDelay: 7 * .2});
		
		FlxTween.num(0, 1, .2, {type:FlxTweenType.ONESHOT, ease:FlxEase.circOut, startDelay: messages.length * .2, onComplete:function(_) {
			ready = true;
		}}, function(Value:Float){
			buttonQuit.alpha = Value;
		});
		
		super.create();
	}
	
}