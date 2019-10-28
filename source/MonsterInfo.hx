package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;

class MonsterInfo extends FlxGroup 
{

	private var monster:FlxSprite;
	private var name:FlxBitmapText;
	
	private var hpBar:FlxSprite;
	private var attBar:FlxSprite;
	private var sdefBar:FlxSprite;
	private var pdefBar:FlxSprite;
	
	private var back:FlxSprite;
	
	private var hpLabel:FlxBitmapText;
	private var attLabel:FlxBitmapText;
	private var pdefLabel:FlxBitmapText;
	private var sdefLabel:FlxBitmapText;
	
	public var alpha(default, set):Float = 1;
	
	public function new(X:Float, Y:Float, MonsterName:String) 
	{
		super();
		
		var mDef:MonsterData = MonsterData.getFromName(MonsterName);
		
		
		monster = new FlxSprite();
		monster.x = X + 2;
		monster.y = Y + 2;
		monster.loadGraphic(AssetPaths.monsters__png, true, 8, 8);
		monster.animation.frameIndex = mDef.id;
		
		name = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.simple_font__png, AssetPaths.simple_font__xml));
		name.text = mDef.name;
		name.borderStyle = FlxTextBorderStyle.SHADOW;
		name.borderColor = 0xff111111;
		name.borderSize = 1;
		name.x = monster.x + monster.width + 2;
		name.y = Y+3;
		
		hpLabel = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.simple_font__png, AssetPaths.simple_font__xml));
		hpLabel.borderStyle = FlxTextBorderStyle.SHADOW;
		hpLabel.borderColor = 0xff111111;
		hpLabel.borderSize = 1;
		hpLabel.text = "H";
		hpLabel.x = X + 2;
		hpLabel.y = monster.y + monster.height + 2;
		
		var amt:Float = FlxMath.lerp(0, 25, mDef.hp / 25);
		amt = Math.max(1, amt);
		hpBar = new FlxSprite();
		hpBar.makeGraphic(Math.round(amt), 4, FlxColor.GREEN);
		hpBar.x = hpLabel.x + hpLabel.width;
		hpBar.y = hpLabel.y+2;
		
		attLabel = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.simple_font__png, AssetPaths.simple_font__xml));
		attLabel.borderStyle = FlxTextBorderStyle.SHADOW;
		attLabel.borderColor = 0xff111111;
		attLabel.borderSize = 1;
		attLabel.text = mDef.att == 0 ? 'é' : 'â';
		attLabel.x = hpLabel.x;
		attLabel.y = hpLabel.y + hpLabel.height;
		
		amt= FlxMath.lerp(0, 25, (mDef.att == 0 ? mDef.satt : mDef.att) / 25);
		if ((mDef.att == 0 ? mDef.satt : mDef.att) > 0)
		{
			amt = Math.max(1, amt);
			attBar = new FlxSprite();
			attBar.makeGraphic(Math.round(amt), 4, mDef.att == 0 ? FlxColor.MAGENTA : FlxColor.RED);
			attBar.x = hpBar.x;
			attBar.y = attLabel.y+2;
		}
		
		pdefLabel = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.simple_font__png, AssetPaths.simple_font__xml));
		pdefLabel.borderStyle = FlxTextBorderStyle.SHADOW;
		pdefLabel.borderColor = 0xff111111;
		pdefLabel.borderSize = 1;
		pdefLabel.text = "P";
		pdefLabel.x = hpLabel.x + hpLabel.width + 53;
		pdefLabel.y = hpLabel.y;
		
		amt= FlxMath.lerp(0, 25, mDef.def / 25);
		if (mDef.def > 0)
		{
			amt = Math.max(1, amt);
			pdefBar = new FlxSprite();
			pdefBar.makeGraphic(Math.round(amt), 4, FlxColor.YELLOW);
			pdefBar.x = pdefLabel.x - amt - 1;
			pdefBar.y = hpBar.y;
		}
		
		
		sdefLabel = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.simple_font__png, AssetPaths.simple_font__xml));
		sdefLabel.borderStyle = FlxTextBorderStyle.SHADOW;
		sdefLabel.borderColor = 0xff111111;
		sdefLabel.borderSize = 1;
		sdefLabel.text = "S";
		sdefLabel.x = hpLabel.x + hpLabel.width + 53;
		sdefLabel.y = attLabel.y;
		
		amt= FlxMath.lerp(0, 25, mDef.sdef / 25);
		if (mDef.sdef > 0)
		{
			amt = Math.max(1, amt);
			sdefBar = new FlxSprite();
			sdefBar.makeGraphic(Math.round(amt), 4, FlxColor.PURPLE);
			sdefBar.x = sdefLabel.x - amt - 1;
			sdefBar.y = sdefLabel.y + 2;
		}
		
		back = new FlxSprite();
		back.loadGraphic(AssetPaths.info_back__png); //new FlxSliceSprite(AssetPaths.dark_frame__png, new FlxRect(2, 2, 2, 2), (hpLabel.width *2) + 56, monster.height + (hpLabel.height*2) + 6);
		back.x = X;
		back.y = Y;
		back.color = FlxColor.fromString("#"+mDef.color);
		
		
		add(back);
		add(name);
		add(monster);
		add(hpLabel);
		add(attLabel);
		add(pdefLabel);
		add(sdefLabel);
		add(hpBar);
		if (attBar!= null)
			add(attBar);
		if (pdefBar!= null)
			add(pdefBar);
		if (sdefBar!= null)
			add(sdefBar);
		
		
	}
	
	private function set_alpha(Value:Float):Float
	{
		alpha = FlxMath.bound(Value, 0, 1);
		
		back.alpha = alpha;
		name.alpha = alpha;
		monster.alpha = alpha;
		hpLabel.alpha = alpha;
		attLabel.alpha = alpha;
		pdefLabel.alpha = alpha;
		sdefLabel.alpha = alpha;
		hpBar.alpha = alpha;
		if (attBar!= null)
			attBar.alpha = alpha;
		if (pdefBar!= null)
			pdefBar.alpha = alpha;
		if (sdefBar!= null)
			sdefBar.alpha = alpha;
		return alpha;
	}
	
}