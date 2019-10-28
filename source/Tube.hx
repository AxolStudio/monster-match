package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;

class Tube extends FlxGroup
{

	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;
	public var whichMonster(default, set):Int = -1;
	public var fillAmount(default, set):Float = 0;

	private var colors:Array<FlxColor> = [FlxColor.RED, FlxColor.YELLOW, FlxColor.GREEN, FlxColor.CYAN, FlxColor.BLUE, FlxColor.MAGENTA, FlxColor.WHITE];

	private var tube:FlxSprite;
	private var fill:FlxSprite;
	private var portrait:FlxSprite;
	private var monsterData:MonsterData;
	private var fillRect:Rectangle;
	private var spawn:FlxSprite;

	public function new(X:Float, Y:Float)
	{
		super();

		fill = new FlxSprite();
		fill.makeGraphic(4, 11, FlxColor.TRANSPARENT, true, "tube+" + X + "-" + Y);
		add(fill);

		portrait = new FlxSprite();
		portrait.loadGraphic(AssetPaths.monsters__png, true, 8, 8);
		portrait.visible = false;
		add(portrait);

		spawn = new FlxSprite();
		spawn.loadGraphic(AssetPaths.spawn__png, true, 8, 8);
		spawn.animation.add("spawn", [0, 1, 2, 3, 4, 5, 2, 3, 4, 5, 6, 7, 8, 9, 10], 12, false);
		spawn.kill();
		add(spawn);

		tube = new FlxSprite();
		tube.loadGraphic(AssetPaths.tube__png);
		add(tube);

		x = X;
		y = Y;

	}

	private function set_whichMonster(Value:Int):Int
	{
		whichMonster = Value;
		if (Value >= 0)
		{
			monsterData = MonsterData.getFromID(whichMonster);

			portrait.animation.frameIndex = monsterData.id;

			fillRect = new Rectangle(0, 9, 4, 2);
			fill.pixels.fillRect(fillRect, FlxColor.WHITE);
			fill.dirty = true;

			portrait.visible = true;
			fill.visible = true;
		}
		else
		{
			fillRect = new Rectangle(0, 9, 4, 2);
			fill.pixels.fillRect(fill.pixels.rect, FlxColor.TRANSPARENT);
			monsterData = null;
			portrait.visible = false;
			fill.visible = false;
		}
		return whichMonster;
	}

	private function set_x(Value:Float):Float
	{
		x = Value;
		tube.x = x;
		fill.x = tube.x + 2;
		portrait.x = tube.x;
		spawn.x = portrait.x;
		return x;
	}

	private function set_y(Value:Float):Float
	{
		y = Value;
		portrait.y = y;
		tube.y = portrait.y + 8;
		fill.y = tube.y + tube.height - 1 - fill.height;
		spawn.y = portrait.y;
		return y;
	}

	private function set_fillAmount(Value:Float):Float
	{
		Value = FlxMath.bound(Value, 0, 1);
		if (Value < fillAmount)
		{
			fill.pixels.fillRect(fill.pixels.rect, FlxColor.TRANSPARENT);
		}
		fillAmount = Value;
		fillRect.height = FlxMath.lerp(2, 11, fillAmount);
		fillRect.y = 11 - Math.floor(fillRect.height);
		fill.pixels.fillRect(fillRect, FlxColor.WHITE); //FlxColor.fromString("#" + monsterData.color));
		fill.dirty = true;

		return fillAmount;
	}

	override public function draw():Void
	{
		if (spawn.alive)
		{
			spawn.color = fill.color = colors[Std.int(((FlxG.game.ticks / 100)  % 7))];

		}
		else if (whichMonster >= 0)
			fill.color = FlxColor.fromString("#" + monsterData.color);

		super.draw();
	}

	public function showSpawn():Void
	{
		spawn.revive();
		spawn.animation.play("spawn", true);
		spawn.animation.finishCallback = function(Anim:String)
		{
			spawn.kill();
		};
	}

}