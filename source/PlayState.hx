package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxSliceSprite;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tile.FlxTileblock;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
using axollib.TitleCase;

class PlayState extends FlxState
{

	public static var SPAWNX:Int = 8;
	public static var SPAWNY:Int = 99;

	public static var HEROSTARTX:Int = 146;
	public static var HEROSTARTY:Int = 98;

	public static var MONSTERSTARTX:Int = 98;
	public static var MONSTERSTARTY:Int = 98;

	public static inline var TIME_BETWEEN_FIGHT:Float = .4;
	public static inline var PROGRESS_AMOUNT:Float = .025;

	public static inline var REFILL_TIME:Float = 15;

	public var blocks:FlxTypedGroup<Block>;
	public var selector:FlxSprite;
	public var selected:FlxSprite;
	public var selectedBlock:Int =-1;
	public var overlappingBlock:Int = -1;
	public var swapping:Bool = false;
	public var numMatchesFound:Int = 0;
	public var anyMatches:Bool = false;

	public var fightingHero:FlxSprite;
	public var fightingMonster:FlxSprite;

	public var currentMonster:Int = -1;
	public var currentHero:Int = -1;
	public var heroHealth:Int = -1;

	public var heroReady:Bool = false;
	public var monsterReady:Bool = false;

	public var fighting:Bool = false;

	public var monsterQueue:Array<Int>;
	public var fightCounter:Float = 0;

	public var progress:ProgressMeter;
	public var backdrop:Environment;
	public var currentEnv:Int = 0;

	public var envLayer:FlxTypedGroup<Environment>;

	public var changingEnv:Bool = false;

	public var thisEnvironment:EnvData;
	public var thisHero:HeroData;

	public var thisMonster:MonsterData;

	public var monstAttAnim:AttackAnim;
	public var heroAttAnim:AttackAnim;

	public var pops:FlxTypedGroup<Pop>;

	public var queueDisp:MonsterQueue;
	public var doChangeEnv:Bool = false;

	public var lich:FlxSprite;
	public var cauldron:FlxSprite;

	public var tubes:Array<Tube>;

	public var firstMatch:Bool = false;

	public var transforms:FlxTypedGroup<Transformer>;
	public var transFormStart:Int = 0;
	public var transFormEnd:Int = 0;

	public var combo:Int = 1;
	public var newCombo:Bool = true;

	public var comboDisp:ComboDisplay;

	public var score:Int = 0;
	public var scoreDisp:ScoreDisplay;

	public var refillBar:FlxBar;
	public var refillTimer:Float = 0;
	private var matchedPotion:Bool = false;

	public var castingSpell:Bool = false;

	public var sprMeteors:Array<Meteor>;
	public var explosions:Array<Explosion>;

	public var shuffleTimes:Int = 0;

	public var envTitle:FlxBitmapText;

	public var monstDmgNo:FlxBitmapText;
	public var heroDmgNo:FlxBitmapText;

	public var heroSkull:FlxSprite;

	public var floatingNumbers:FlxTypedGroup<FloatingNumber>;

	public var mapPoints:Array<FlxSprite>;
	public var mapPaths:Array<FlxSprite>;

	public var heroCounter:FlxBitmapText;
	
	public var ready:Bool = false;
	
	public var lastStep:Int = -1;
	
	public var pauseButton:FlxSpriteButton;
	
	public var juices:FlxTypedGroup<Juice>;
	
	public var barrier:Barrier;

	override public function create():Void
	{
		
		
		
		ready = false;

		Counts.clear();

		Counts.add("monsters_spawned", 0);
		Counts.add("heroes_defeated", 0);
		Counts.add("spells_cast", 0);
		Counts.add("highest_area", 1);

		
		changingEnv = true;

		thisEnvironment = EnvData.getFromID(currentEnv);

		createUI();

		buildGrid();

		selector = new FlxSprite();
		selector.loadGraphic(AssetPaths.selecting__png);
		selector.visible = false;
		add(selector);

		selected = new FlxSprite();
		selected.loadGraphic(AssetPaths.selected__png);
		selected.visible = false;
		add(selected);

		createHero();
		createMonster();
		createBarrier();

		monsterQueue = [];

		//envTitle.text =  thisEnvironment.name.toTitleCase();
		showMap();

		super.create();
		
		Sounds.playMusic("gameloop");
		
		FlxG.camera.fade(FlxColor.BLACK, 1, true, function() {
			ready = true;
			dropNewBlocks();
		});
	}

	
	
	public function showMap():Void
	{
		if (currentEnv > 0)
		{
			mapPaths[currentEnv - 1].revive();
			FlxSpriteUtil.stopFlickering(mapPoints[currentEnv - 1]);
			mapPoints[currentEnv - 1].alpha = .66;
		}

		mapPoints[currentEnv].alpha = 1;
		FlxSpriteUtil.flicker(mapPoints[currentEnv], 0, .2, true);

	}

	public function returnFromSpellChoice(Selection:Int):Void
	{
		// actually cast spell in the future
		//castingSpell = false;

		Counts.add("spells_cast", 1);
		
		switch (Selection)
		{
			case 0:
				shuffleMonsters();
			case 1:
				removeMinority();
			case 2:
				meteors();

			default:

		}
	}
	
	private function createBarrier():Void
	{
		barrier = new Barrier();
		barrier.x = backdrop.x + 27;
		barrier.y = backdrop.y;
		add(barrier);
	}

	private function shuffleMonsters():Void
	{
		var tmp:Array<Block> = [];
		var types:Array<Int> = [];
		for (b in blocks)
		{
			if (b.alive)
			{
				tmp.push(b);
				types.push(b.isPotion ? -99 : b.animation.frameIndex);
			}
		}

		shuffleTimes = 0;
		
		var whichSound:Int = -1;
		
		new FlxTimer().start(.1, function(T:FlxTimer)
		{
			whichSound = FlxG.random.int(1, 4, [whichSound]);
			Sounds.play("boop_0" + Std.string(whichSound), .33);
			FlxG.random.shuffle(types);
			for (i in 0...types.length)
			{
				if (tmp[i].isPotion)
					tmp[i].isPotion = false;
				if (tmp[i].skull)
					tmp[i].skull = false;
				if (types[i] == 40)
				{
					tmp[i].skull = true;
				}
				else if (types[i] == -99)
				{
					tmp[i].isPotion = true;
				}
				else
				{
					tmp[i].animation.frameIndex = types[i];
				}
			}

			shuffleTimes++;

			
			
			if (shuffleTimes < 10)
			{
				
				T.reset(.1);
			}
			else
			{
				combo = 1;
				newCombo = true;
				matchedPotion = false;
				swapping = true;
				findMatches();

				castingSpell = false;
			}
		});

	}

	private function removeMinority():Void
	{
		
		var matches:Array<MatchData> = [];
		
		var targetType:String = FlxG.random.getObject(thisEnvironment.monsters);
		var mID:Int = MonsterData.getFromName(targetType).id;

		// show animation of selecting the monster?
		
		for (b in blocks)
		{
			if (b.alive)
			{
				if (b.animation.frameIndex == mID)
				{
					b.isMatched = true;
					anyMatches = true;
					matches.push({
							source: FlxPoint.get(b.x, b.y),
							whichMonster: b.animation.frameIndex,
							count: 1,
							potion: b.isPotion,
							skull: b.skull
						});
				}
			}
		}

		combo = 1;
		newCombo = true;
		matchedPotion = false;
		swapping = true;
		
		
		for (m in matches)
		{
			
			if (m.potion)
			{
				matchedPotion = true;
				giveScore(10);
				Sounds.play("potion", .66);
			}
			else if (m.skull)
			{
				giveScore(2);
				Sounds.play("skull_crush", .33);
			}
			else
			{
				addToTubes(m.source.x, m.source.y, m.whichMonster, m.count, 0, true);
				//giveScore(MonsterData.getFromID(m.whichMonster).hp * m.count * combo);
				Sounds.play("match",.66);
			}

		}
		
		destroyMatches();

		castingSpell = false;

	}

	private function countNeighbors(X:Int, Y:Int):Int
	{
		var neighbors:Int = 0;
		for (x in (X - 1)...(X + 2))
		{
			for (y in (Y - 1)...(Y + 2))
			{
				if (x >= 0 && x < 8 && y >= 0 && y < 8)
				{
					if (findBlock(SPAWNX + (10 * x), SPAWNY - (10 * y)) != null )
						neighbors++;
				}
			}
		}
		return neighbors;
	}

	private function meteors():Void
	{
		var targets:Array<FlxPoint> = [];

		var matches:Array<MatchData> = [];
		
		var b:Block = null;
		for (x in 0...8)
		{
			for (y in 0...8)
			{

				//if (findBlock(SPAWNX + (x * 10), SPAWNY - (y * 10)) != null)
				if (countNeighbors(x,y) >=3)
					targets.push(FlxPoint.get(x, y));

			}
		}
		
		FlxG.random.shuffle(targets);
		
		for (i in 0...3)
		{
			if (targets.length <= i)
				break;

			//b = findBlock(SPAWNX + (targets[i].x * 10), SPAWNY - (targets[i].y * 10));

			for (x in Std.int(targets[i].x -1)...Std.int(targets[i].x + 2))
			{
				for (y in Std.int(targets[i].y -1)...Std.int(targets[i].y + 2))
				{
					b = findBlock(SPAWNX + (x * 10), SPAWNY - (y * 10));
					if (b != null)
					{
						b.isMatched = true;
						anyMatches = true;
						
						matches.push({
							source: FlxPoint.get(b.x, b.y),
							whichMonster: b.animation.frameIndex,
							count: 1,
							potion: b.isPotion,
							skull: b.skull
						});
						
					}
				}
			}

			

			sprMeteors[i].start(SPAWNX + (targets[i].x * 10), SPAWNY - (targets[i].y * 10), i * .2, i == 2 ? function()
			{
				explosions[i].start(sprMeteors[i].targetX, sprMeteors[i].targetY);
				FlxG.camera.shake(0.05,0.1);
				combo = 1;
				newCombo = true;
				matchedPotion = false;
				swapping = true;
				
				
				for (m in matches)
				{
					
					if (m.potion)
					{
						matchedPotion = true;
						giveScore(10);
						Sounds.play("potion", .66);
					}
					else if (m.skull)
					{
						giveScore(2);
						Sounds.play("skull_crush", .33);
					}
					else
					{
						addToTubes(m.source.x, m.source.y, m.whichMonster, m.count, 0, true);
						//giveScore(MonsterData.getFromID(m.whichMonster).hp * m.count * combo);
						Sounds.play("match",.66);
					}

				}
				
				
				destroyMatches();

				castingSpell = false;
			} : function()
			{
				explosions[i].start(sprMeteors[i].targetX, sprMeteors[i].targetY);
				Sounds.play("meteor_impact_0" + Std.string(i+1), .66);
				FlxG.camera.shake(0.05,0.1);
			});

		}
		targets = FlxDestroyUtil.putArray(targets);

	}

	private function findBlock(X:Float, Y:Float):Block
	{
		for (b in blocks)
		{
			if (b.alive)
			{
				if (b.x == X && b.y == Y)
					return b;
			}
		}
		return null;
	}

	private function createHero():Void
	{
		fightingHero = new FlxSprite(HEROSTARTX, HEROSTARTY);
		fightingHero.loadGraphic(AssetPaths.heroes__png, true, 8, 8);
		fightingHero.flipX = true;
		fightingHero.alpha = 0;
		add(fightingHero);

		heroAttAnim = new AttackAnim();
		heroAttAnim.x = 126;
		heroAttAnim.y = fightingHero.y;
		add(heroAttAnim);
	}

	private function createMonster():Void
	{
		fightingMonster = new FlxSprite(MONSTERSTARTX, MONSTERSTARTY);
		fightingMonster.loadGraphic(AssetPaths.monsters__png, true, 8, 8);
		fightingMonster.alpha = 0;
		add(fightingMonster);

		monstAttAnim = new AttackAnim();
		monstAttAnim.x = 118;
		monstAttAnim.y = fightingMonster.y;
		add(monstAttAnim);
	}

	private function createUI():Void
	{
		var bg:FlxTileblock = new FlxTileblock( -3, -2, 170, 130);
		bg.loadTiles(AssetPaths.background__png, 10, 10);
		add(bg);

		var backColor:FlxTileblock = new FlxTileblock(7, 28, 80, 80);
		backColor.loadTiles(AssetPaths.grid_back__png, 10, 10);
		add(backColor);

		blocks = new FlxTypedGroup<Block>();
		add(blocks);

		pops = new FlxTypedGroup<Pop>();
		add(pops);

		transforms = new FlxTypedGroup<Transformer>();
		add(transforms);

		var t:Transformer = null;
		for (tx in 0...8)
		{
			for (ty in 0...tx+1)
			{
				t = new Transformer(SPAWNX + (10 * (tx - ty)), SPAWNY - (10 * ty));
				transforms.add(t);
			}
		}

		for (ty in 1...8)
		{
			for (tx in 0...(8-ty))
			{
				t = new Transformer(SPAWNX + (10 * (7 - tx)), SPAWNY - (10 * (ty+tx)));
				transforms.add(t);
			}
		}

		var border:FlxSliceSprite = new FlxSliceSprite(AssetPaths.GameFieldBottom__png, new FlxRect(2, 2, 2, 2), 5, 124);
		border.x = 2;
		border.y = -2;
		add(border);

		border = new FlxSliceSprite(AssetPaths.GameFieldBottom__png, new FlxRect(2, 2, 2, 2), 5, 124);
		border.x = 87;
		border.y = -2;
		add(border);

		var top:FlxSliceSprite = new FlxSliceSprite(AssetPaths.GameFieldBottom__png, new FlxRect(2, 2, 2, 2), 84, 30);
		top.x = 5;
		top.y = 108;
		add(top);

		top = new FlxSliceSprite(AssetPaths.GameFieldBottom__png, new FlxRect(2, 2, 2, 2), 84, 31);
		top.x = 5;
		top.y = -3;
		top.angle = 180;
		add(top);

		lich = new FlxSprite(8, 18, AssetPaths.lich_lord__png);
		add(lich);

		cauldron = new FlxSprite(16, 18);
		cauldron.loadGraphic(AssetPaths.cauldron__png, true, 8, 8);
		cauldron.animation.add("normal", [0]);
		cauldron.animation.add("burst", [1, 2, 3, 4, 5, 0], 8, false);
		cauldron.animation.play("normal");
		add(cauldron);

		comboDisp = new ComboDisplay(cauldron.x + (cauldron.width / 2) - (4), cauldron.y - 8 - 4);
		add(comboDisp);

		tubes = [];
		var t:Tube = null;
		for (i in 0...6)
		{
			t = new Tube(16 + 12 + (i * 10), 18 + 8 - 24);
			tubes.push(t);
			add(t);
		}

		floatingNumbers = new FlxTypedGroup<FloatingNumber>();
		add(floatingNumbers);

		var scoreback:FlxSprite = new FlxSprite(96, 3, AssetPaths.score_back__png);
		add(scoreback);

		scoreDisp = new ScoreDisplay();
		scoreDisp.x = scoreback.x+2;
		scoreDisp.y = scoreback.y+2;
		add(scoreDisp);
		scoreDisp.text = "0";

		border = new FlxSliceSprite(AssetPaths.GameFieldBottom__png, new FlxRect(2, 2, 2, 2), 64, 40);
		border.x = 94;
		border.y = 21;
		border.angle = 180;
		add(border);

		queueDisp = new MonsterQueue(this);
		queueDisp.x = border.x + 2;
		queueDisp.y = border.y + 2;
		add(queueDisp);

		envLayer = new FlxTypedGroup<Environment>();
		add(envLayer);

		backdrop = new Environment(border.x + 2, border.y + 5, 0);
		envLayer.add(backdrop);

		envTitle = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.fancy_font__png, AssetPaths.fancy_font__xml));
		envTitle.x = backdrop.x;
		envTitle.y = backdrop.y + backdrop.height;
		envTitle.autoSize = false;
		envTitle.alignment = FlxTextAlign.CENTER;
		envTitle.fieldWidth = Std.int(backdrop.width);
		envTitle.text = thisEnvironment.name.toTitleCase();
		envTitle.borderStyle = FlxTextBorderStyle.SHADOW;
		envTitle.borderColor = 0xff333333;
		envTitle.borderSize = 1;
		add(envTitle);

		progress = new ProgressMeter(backdrop.x, envTitle.y + envTitle.height);

		add(progress);

		heroCounter = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.tiny_digits__png, AssetPaths.tiny_digits__xml));

		heroCounter.autoSize = false;
		heroCounter.fieldWidth = 30;
		heroCounter.alignment = FlxTextAlign.RIGHT;
		heroCounter.borderColor = 0xff333333;
		heroCounter.borderStyle = FlxTextBorderStyle.OUTLINE;
		heroCounter.borderSize = 1;
		heroCounter.text = "*20";
		heroCounter.x = backdrop.x + backdrop.width - 31;
		heroCounter.y = backdrop.y + backdrop.height - heroCounter.height+1;
		heroCounter.alpha = 0;
		add(heroCounter);

		MONSTERSTARTY = HEROSTARTY = Std.int(backdrop.y + backdrop.height - 8 - 1);

		monstDmgNo = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.tiny_digits__png, AssetPaths.tiny_digits__xml));
		monstDmgNo.text = "0";
		monstDmgNo.x = 0;
		monstDmgNo.y = MONSTERSTARTY - 6;
		monstDmgNo.alignment = FlxTextAlign.CENTER;
		monstDmgNo.borderStyle  = FlxTextBorderStyle.OUTLINE;
		monstDmgNo.borderColor = 0xff111111;
		monstDmgNo.borderSize = 1;
		monstDmgNo.alpha = 0;
		add(monstDmgNo);

		heroDmgNo = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.tiny_digits__png, AssetPaths.tiny_digits__xml));
		heroDmgNo.text = "0";
		heroDmgNo.x = 0;
		heroDmgNo.y = MONSTERSTARTY - 6;
		heroDmgNo.alignment = FlxTextAlign.CENTER;
		heroDmgNo.borderStyle  = FlxTextBorderStyle.OUTLINE;
		heroDmgNo.borderColor = 0xff111111;
		heroDmgNo.borderSize = 1;
		heroDmgNo.alpha = 0;
		add(heroDmgNo);

		heroSkull = new FlxSprite();
		heroSkull.loadGraphic(AssetPaths.skull__png, false);
		heroSkull.flipX = true;
		heroSkull.alpha = 0;
		heroSkull.kill();
		add(heroSkull);

		refillBar = new FlxBar(7, 110, FlxBarFillDirection.LEFT_TO_RIGHT, 80, 10, this, "refillTimer", 0, REFILL_TIME, true);
		refillBar.createImageBar(AssetPaths.refill_empty__png, AssetPaths.refill_fill__png);
		add(refillBar);

		sprMeteors = [new Meteor(),  new Meteor(), new Meteor()];// , new Meteor(), new Meteor()];
		add(sprMeteors[0]);
		add(sprMeteors[1]);
		add(sprMeteors[2]);

		explosions = [new Explosion(), new Explosion(), new Explosion()];
		add(explosions[0]);
		add(explosions[1]);
		add(explosions[2]);

		var mapBack:FlxSliceSprite = new FlxSliceSprite(AssetPaths.spell_back__png, new FlxRect(7, 7, 41, 17), 64, 54);
		mapBack.x = 94;
		mapBack.y = 63;
		add(mapBack);

		var map:FlxSprite = new FlxSprite(mapBack.x+3, mapBack.y+3, AssetPaths.map__png);
		add(map);

		mapPaths = [];
		mapPoints = [];

		var mP:FlxSprite = new FlxSprite(map.x, map.y, AssetPaths.map_path_0__png);
		mapPaths.push(mP);
		mP.alpha = .66;
		mP.kill();
		add(mP);

		mP = new FlxSprite(map.x, map.y, AssetPaths.map_path_1__png);
		mapPaths.push(mP);
		mP.alpha = .66;
		mP.kill();
		add(mP);

		mP = new FlxSprite(map.x, map.y, AssetPaths.map_path_2__png);
		mapPaths.push(mP);
		mP.alpha = .66;
		mP.kill();
		add(mP);

		mP = new FlxSprite(map.x, map.y, AssetPaths.map_path_3__png);
		mapPaths.push(mP);
		mP.alpha = .66;
		mP.kill();
		add(mP);

		mP = new FlxSprite(map.x, map.y, AssetPaths.map_path_4__png);
		mapPaths.push(mP);
		mP.alpha = .66;
		mP.kill();
		add(mP);

		mP = new FlxSprite(map.x, map.y, AssetPaths.map_path_5__png);
		mapPaths.push(mP);
		mP.alpha = .66;
		mP.kill();
		add(mP);

		mP  = new FlxSprite(map.x + 13, map.y + 38, AssetPaths.map_node__png);
		mapPoints.push(mP);
		mP.alpha = .33;
		add(mP);

		mP  = new FlxSprite(map.x + 40, map.y + 37, AssetPaths.map_node__png);
		mapPoints.push(mP);
		mP.alpha = .33;
		add(mP);

		mP  = new FlxSprite(map.x + 41, map.y + 27, AssetPaths.map_node__png);
		mapPoints.push(mP);
		mP.alpha = .33;
		add(mP);

		mP  = new FlxSprite(map.x + 21, map.y + 25, AssetPaths.map_node__png);
		mapPoints.push(mP);
		mP.alpha = .33;
		add(mP);

		mP  = new FlxSprite(map.x + 6, map.y + 27, AssetPaths.map_node__png);
		mapPoints.push(mP);
		mP.alpha = .33;
		add(mP);

		mP  = new FlxSprite(map.x + 11, map.y + 8, AssetPaths.map_node__png);
		mapPoints.push(mP);
		mP.alpha = .33;
		add(mP);

		mP  = new FlxSprite(map.x + 2, map.y + 3, AssetPaths.map_node__png);
		mapPoints.push(mP);
		mP.alpha = .33;
		add(mP);

		pauseButton = new FlxSpriteButton(FlxG.width - 12, FlxG.height - 14, null, pauseGame);
		pauseButton.loadGraphic(AssetPaths.pause_button__png, true, 10, 12);
		add(pauseButton);
		
		juices = new FlxTypedGroup<Juice>();
		add(juices);
		
	}
	
	public function spawnJuice(StartX:Float, StartY:Float, Color:String, DestX:Float, DestY:Float):Void
	{
		var j:Juice = juices.recycle(Juice);
		j.start(StartX, StartY, Color, DestX, DestY);
		juices.add(j);
	}

	public function getFromArrayWithExclusions<T>(Objects:Array<T>, ?Exclusions:Array<T>):T
	{
		var selected:Null<T> = null;
		var attempts:Int = 0;

		if (Objects.length != 0)
		{
			do
			{
				selected = FlxG.random.getObject(Objects);
				if (Exclusions != null)
				{
					if (Exclusions.length != 0)
					{
						if (Exclusions.indexOf(selected) != -1)
						{
							selected = null;
							attempts++;
						}
					}
				}

			}
			while (selected == null || attempts > 20);
		}

		return selected;
	}

	private function buildGrid():Void
	{

		var monsterList:Array<Int> = [];

		for (m in thisEnvironment.monsters)
		{
			monsterList.push(MonsterData.getFromName(m).id);
		}

		for (y in 0...8)
		{
			for (x in 0...8)
			{
				var b:Block = new Block();
				b.x = (SPAWNX + (x * 10));
				b.baseY = (SPAWNY - (y * 10));
				b.y = b.baseY;
				b.animation.frameIndex = getFromArrayWithExclusions(monsterList);
				b.ID = (8 * y) + x;
				b.isNew = true;
				blocks.add(b);
			}
		}

		fixPreMatches(monsterList);
		
		for (b in blocks)
		{
			if (b.alive && b.isNew)
			{
				b.y = b.baseY - FlxG.height;
			}
		}
		
	}

	private function dropNewBlocks():Void
	{
		for (b in blocks)
		{
			if (b.alive && b.isNew)
			{
				b.y = b.baseY - FlxG.height;
			}
		}

		Sounds.play("new_blocks");
		
		FlxTween.num(0, 1, .66, {type:FlxTweenType.ONESHOT, ease:FlxEase.quadIn, onComplete:function(_)
		{

			for (b in blocks)
			{
				if (b.alive && b.isNew)
				{
					b.y = b.baseY;
					b.isNew = false;
				}
			}
			if (changingEnv)
			{
				changingEnv = false;
			}
			else
			{
				findMatches();
			}
		}
								},function(Value:Float)
		{
			for (b in blocks)
			{
				if (b.isNew && b.alive)
				{

					b.y = FlxMath.lerp(b.baseY - FlxG.height, b.baseY, Value);

				}
			}
		});
	}

	private function fixPreMatches(MonsterList:Array<Int>):Void
	{
		var numMatches:Int = 0;
		var lastMatch:Int = -1;
		var anyMatches:Bool = false;

		do
		{
			anyMatches = false;
			for (y in 0...8)
			{
				lastMatch = -1;
				numMatches = 0;

				for (x in 0...8)
				{

					for (b in blocks)
					{
						if (!b.alive)
						{
							numMatches = 0;
							lastMatch = -1;
						}
						else if (b.x == (SPAWNX + (x * 10)) && b.y == (SPAWNY - (y * 10)))
						{
							if (lastMatch == b.animation.frameIndex)
							{
								numMatches++;
								if (numMatches >= 2 && b.isNew)
								{
									b.animation.frameIndex = getFromArrayWithExclusions(MonsterList, [lastMatch]);
									numMatches = 0;
									anyMatches = true;

								}
							}

							lastMatch = b.animation.frameIndex;

							break;
						}

					}
				}
			}

			for (x in 0...8)
			{
				lastMatch = -1;
				numMatches = 0;

				for (y in 0...8)
				{
					for (b in blocks)
					{

						if (!b.alive)
						{
							numMatches = 0;
							lastMatch = -1;
						}
						else if (b.x == (SPAWNX + (x * 10)) && b.y == (SPAWNY - (y * 10)))
						{
							if (lastMatch == b.animation.frameIndex)
							{
								numMatches++;
								if (numMatches >= 2 && b.isNew)
								{
									b.animation.frameIndex = getFromArrayWithExclusions(MonsterList, [lastMatch]); //FlxG.random.int(0, 3, [lastMatch]);
									numMatches = 0;
									anyMatches = true;

								}
							}
							lastMatch = b.animation.frameIndex;

							break;
						}
					}
				}
			}
		}
		while (anyMatches);
	}

	private function fillNewColumn():Void
	{
		var monsterList:Array<Int> = [];
		var b:Block = null;
		var newBlocks:Array<Block> = [];

		for (m in thisEnvironment.monsters)
		{
			monsterList.push(MonsterData.getFromName(m).id);
		}

		for (y in 0...8)
		{
			b = blocks.recycle(Block);
			b.revive();
			b.x = SPAWNX;
			b.y = SPAWNY - (y * 10);
			b.isMatched = b.matchedX = b.matchedY = false;
			b.isPotion = false;
			b.animation.frameIndex = getFromArrayWithExclusions(monsterList);
			b.scale.set(0.001, 0.001);
			b.alpha = 0;
			blocks.add(b);
			newBlocks.push(b);
		}

		FlxTween.num(0, 1, .33, {
			type:FlxTweenType.ONESHOT, ease:FlxEase.circInOut, onComplete:function(_)
			{
				condenseEmptyColumns();
			}
		}, function(Value:Float)
		{
			for (b in newBlocks)
			{
				var s:Float = FlxMath.lerp(0.001, 1, Value);
				b.scale.set(s, s);
				b.alpha = Value;
			}
		});

	}

	public function fillWithNewBlocks():Void
	{
		var monsterList:Array<Int> = [];

		for (m in thisEnvironment.monsters)
		{
			monsterList.push(MonsterData.getFromName(m).id);
		}

		var b:Block = null;
		var blockExists:Bool = false;

		for (y in 0...8)
		{
			for (x in 0...8)
			{
				blockExists = false;
				for (b in blocks)
				{
					if (!b.alive) continue;
					if (b.x == SPAWNX + (x * 10) && b.y == SPAWNY - (y * 10))
					{
						blockExists = true;
						break;
					}
				}
				if (!blockExists)
				{
					b = blocks.recycle(Block);
					b.revive();
					b.x = SPAWNX + (x * 10);
					b.y = SPAWNY - (y * 10);
					b.baseY = b.y;
					b.isMatched = b.matchedX = b.matchedY = false;
					b.isPotion = false;
					b.animation.frameIndex = getFromArrayWithExclusions(monsterList);
					b.scale.set(1, 1);
					b.alpha = 1;
					b.isNew = true;
					blocks.add(b);
				}
			}
		}
		fixPreMatches(monsterList);
		dropNewBlocks();

	}

	private function spawnHero():Void
	{
		if (currentHero == HeroData.count() - 1)
		{
			// that was the last hero! VICTORY!
			score+= 10000;
			openSubState(new GameOver(true, score));
		}
		else
		{
			currentHero++;
			heroCounter.text = "*" + Std.string(20 - currentHero);
			FlxTween.tween(heroCounter, {alpha:1}, .2, {type:FlxTweenType.ONESHOT, ease:FlxEase.circIn});
			thisHero = HeroData.getFromID(currentHero);
			heroHealth = thisHero.hp;
			fightingHero.animation.frameIndex = currentHero;

			FlxTween.color(fightingHero, .5, FlxColor.fromRGB(0,0,0,0), FlxColor.WHITE, {type:FlxTweenType.ONESHOT, ease:FlxEase.circInOut});
			FlxTween.tween(fightingHero, {x:130}, .5, {
				type:FlxTweenType.ONESHOT, ease:FlxEase.circInOut, onComplete:function(_)
				{
					heroReady = true;
				}
			});
		}

	}

	public function triggerNewEnv():Void
	{
		doChangeEnv = true;
	}

	public function nextEnv():Void
	{
		Sounds.play("finished_area", .66);
		if (currentEnv == EnvData.count()-1)
		{
			// we just finished the final environment!!! GAME OVER!
			openSubState(new GameOver(false, score));

		}
		else
		{

			
			currentEnv++;
			Counts.increaseIfHigher("highest_area", currentEnv);
			showMap();
			changingEnv = true;
			doChangeEnv = false;

			transFormStart = 0;
			transFormEnd = 0;
			var tmr:FlxTimer = new FlxTimer();
			doTrans(tmr);
		}
	}

	private function finishNewEnv():Void
	{
		var bHp:Int = 0;
		var amt:Int = 0;
		for (t in tubes)
		{
			amt = Std.int(t.fillAmount * 10 * currentEnv);
			if (amt > 0)
			{
				spawnJuice(t.x + 4, t.y + 12, MonsterData.getFromID(t.whichMonster).color, backdrop.x + 30, backdrop.y + 8);
				
				bHp += amt;
			}
			
			
			t.whichMonster =-1;
			
			
			
			t.fillAmount = 0;
		}
		
		if (bHp > 0)
		{
			barrier.health = bHp;
			new FlxTimer().start(.33,function(_){
				barrier.revive();
				Sounds.play("make_barrier", .33);
			});
		}
		

		thisEnvironment = EnvData.getFromID(currentEnv);
		envTitle.text = thisEnvironment.name.toTitleCase();
		var newEnv:Environment = new Environment(backdrop.x, backdrop.y, currentEnv);
		envLayer.add(newEnv);
		newEnv.alpha = 0;
		newEnv.progress = 0;
		progress.progress = 0;
		FlxTween.tween(newEnv, {alpha:1}, .5, {
			type:FlxTweenType.ONESHOT, ease:FlxEase.circInOut, onComplete:function(_)
			{
				var oldEnv:Environment = backdrop;
				oldEnv.kill();
				envLayer.replace(oldEnv, newEnv);
				oldEnv = FlxDestroyUtil.destroy(oldEnv);

				backdrop = newEnv;
				heroReady = true;
				changingEnv = false;

				fillWithNewBlocks();

			}
		});

	}

	public function doTrans(tmr:FlxTimer):Void
	{
		var t:Transformer = null;

		for (i in transFormStart...(transFormStart+transFormEnd+1))
		{

			t = transforms.members[i];

			t.start();
			for (b in blocks)
			{
				if (b.alive && !b.isPotion)
				{
					if (b.x == t.x && b.y == t.y)
					{
						Sounds.play("to_skull", .2);
						b.skull = true;
						break;
					}
				}
			}

		}

		transFormStart += transFormEnd + 1;

		if (transFormStart <= 35)
		{
			transFormEnd++;
		}
		else
		{
			transFormEnd--;
		}

		if (transFormEnd == 8)
			transFormEnd--;

		if (transFormEnd < 0)
		{
			matchedPotion = false;
			combo = 1;
			newCombo = true;
			findMatches();
		}
		else
		{

			tmr.start(.1, doTrans);
		}
	}

	public function doCombat(elapsed:Float):Void
	{
		if ((heroReady || currentHero == -1) && (monsterReady || currentMonster == -1))
		{

			fightCounter += elapsed;
			if (fightCounter >= TIME_BETWEEN_FIGHT)
			{
				fightCounter -= TIME_BETWEEN_FIGHT;

				if (currentHero == -1 && firstMatch)
				{

					spawnHero();
					return;
				}
				if (currentMonster == -1)
				{
					if (spawnMonster())
						return;
				}
				
				// there is a barrier!
				if (barrier.alive)
				{
					
					heroReady = false;
					FlxTween.tween(fightingHero, {x:fightingHero.x - 4}, .5, {type:FlxTweenType.ONESHOT, ease:FlxEase.backIn, onComplete:function(_)
						{
							barrier.hurt(thisHero.att + thisHero.satt);
							Sounds.play("hit_barrier", .33);

							FlxTween.tween(fightingHero, {x:fightingHero.x + 4}, .5, {type:FlxTweenType.ONESHOT, ease:FlxEase.backOut, onComplete:function(_)
								{
									
									heroReady = true;
								}
							});
						}
					});
				}
				else
				{
				
					if (heroReady && currentMonster == -1)
					{
						// NO MONSTER TO BLOCK!!!
						// advance exploration progress??
						
						progress.progress += PROGRESS_AMOUNT;
						backdrop.progress = progress.progress;
						
						heroReady = false;
						FlxTween.tween(fightingHero, {x:fightingHero.x - 4}, .5, {type:FlxTweenType.ONESHOT, ease:FlxEase.backIn, onComplete:function(_)
							{
								
								lastStep = FlxG.random.int(1, 2, [lastStep]);
								Sounds.play("step_0" + Std.string(lastStep));
								
								
								FlxTween.tween(fightingHero, {x:fightingHero.x + 4}, .5, {type:FlxTweenType.ONESHOT, ease:FlxEase.backOut, onComplete:function(_)
									{
										if (progress.progress == 1)
										{
											triggerNewEnv();
										}
										else
										{
											heroReady = true;
										}
									}
								});

							}
						});
					}

				
					else if (heroReady && monsterReady)
					{

						heroReady = monsterReady = false;

						var mRoll:Int=0;
						var hRoll:Int=0;

						var mPDmg:Int = -1;
						var mSDmg:Int = -1;
						if (thisHero.att != 0)
						{
							mPDmg = 1;

							hRoll = FlxG.random.int(1, 20) + thisHero.att;
							mRoll = thisMonster.def + 10;

							if (hRoll >= mRoll)
								mPDmg = FlxMath.maxInt(thisHero.att - thisMonster.def, 1);
						}
						if (thisHero.satt != 0)
						{
							mSDmg = 1;

							hRoll = FlxG.random.int(1, 20) + thisHero.satt;
							mRoll = thisMonster.sdef + 10;

							if (hRoll >= mRoll)
								mSDmg = FlxMath.maxInt(thisHero.satt - thisMonster.sdef, 1);

						}

						var hPDmg:Int = -1;
						var hSDmg:Int = -1;
						if (thisMonster.att != 0)
						{
							hPDmg = 0;

							mRoll = FlxG.random.int(1, 20) + thisMonster.att;
							hRoll = thisHero.def + 10;

							if (mRoll >= hRoll)
								hPDmg = FlxMath.maxInt(thisMonster.att - thisHero.def, 1);

						}
						if (thisMonster.satt != 0)
						{
							hSDmg = 0;

							mRoll = FlxG.random.int(1, 20) + thisMonster.satt;
							hRoll = thisHero.sdef + 10;

							if (mRoll >= hRoll)
								hSDmg = FlxMath.maxInt(thisMonster.satt - thisHero.sdef, 1);
						}

						// move enemies towards each other, check combat, show results, move back.
						FlxTween.tween(fightingMonster, {x:fightingMonster.x + 4}, .5, {type:FlxTweenType.ONESHOT, ease:FlxEase.backIn, onComplete:function(_)
						{
							if (mSDmg < 0)
							{
								if (mPDmg == 0)
								{
									monstAttAnim.playEffect("physblock");
									showMonsterDamage(0);
									Sounds.play("block", .33);
								}
								else if (mPDmg > 0)
								{
									monstAttAnim.playEffect("physhit");
									thisMonster.hp -= mPDmg;
									showMonsterDamage(mPDmg);
									Sounds.play("damage", .33);
								}
							}
							else if (mSDmg == 0)
							{
								monstAttAnim.playEffect("magblock");
								showMonsterDamage(0);
								Sounds.play("block", .33);
							}
							else if (mSDmg > 0)
							{
								monstAttAnim.playEffect("maghit");
								thisMonster.hp -= mSDmg;
								showMonsterDamage(mSDmg);
								Sounds.play("damage", .33);
							}
							if (thisMonster.hp > 0)
							{
								FlxTween.tween(fightingMonster, {x:fightingMonster.x - 4}, .5, {type:FlxTweenType.ONESHOT, ease:FlxEase.backOut, onComplete:function(_)
								{
									monsterReady = true;
								}
																							   });
							}
							else
							{
								// KILL THE MONSTER!
								Sounds.play("death");
								FlxTween.color(fightingMonster, .5, FlxColor.WHITE, FlxColor.fromRGB(255, 0, 0, 0), {type:FlxTweenType.ONESHOT, ease:FlxEase.circInOut, onComplete:function(_)
								{
									fightingMonster.x = MONSTERSTARTX;
									currentMonster = -1;

								}
																													});
							}
						}
																					   });
						FlxTween.tween(fightingHero, {x:fightingHero.x - 4}, .5, {type:FlxTweenType.ONESHOT, ease:FlxEase.backIn, onComplete:function(_)
						{
							if (hSDmg < 0)
							{
								if (hPDmg == 0)
								{
									heroAttAnim.playEffect("physblock");
									showHeroDamage(0);
									Sounds.play("block", .33);
								}
								else if (hPDmg > 0)
								{
									heroAttAnim.playEffect("physhit");
									heroHealth -= hPDmg;
									showHeroDamage(hPDmg);
									Sounds.play("damage", .33);
								}
							}
							else if (hSDmg == 0)
							{
								heroAttAnim.playEffect("magblock");
								showHeroDamage(0);
								Sounds.play("block", .33);
							}
							else if (hSDmg > 0)
							{
								heroAttAnim.playEffect("maghit");
								heroHealth -= hSDmg;
								showHeroDamage(hSDmg);
								Sounds.play("damage", .33);
							}
							if (heroHealth > 0)
							{
								FlxTween.tween(fightingHero, {x:fightingHero.x + 4}, .5, {type:FlxTweenType.ONESHOT, ease:FlxEase.backOut, onComplete:function(_)
								{

									heroReady = true;

								}
																						 });
							}
							else
							{
								//KILL THE HERO!
								giveScore(HeroData.getFromID(currentHero).hp * 100);
								Counts.add("heroes_defeated", 1);
								Sounds.play("death");
								FlxTween.tween(heroCounter, {alpha:0}, .2, {type:FlxTweenType.ONESHOT, ease:FlxEase.circOut});
								showHeroSkull();
								FlxTween.color(fightingHero, .5, FlxColor.WHITE, FlxColor.fromRGB(255, 0, 0, 0), {type:FlxTweenType.ONESHOT, ease:FlxEase.circInOut, onComplete:function(_)
								{
									fightingHero.x = HEROSTARTX;
									spawnHero();
								}
																												 });
							}
						}
																				 });
					}
				}
			}
		}
		else
			fightCounter = 0;

	}

	public function showHeroSkull():Void
	{
		heroSkull.reset(fightingHero.x + 6, fightingHero.y);
		heroSkull.alpha = 0;

		FlxTween.tween(heroSkull, {alpha:.8}, .2, {
			type:FlxTweenType.ONESHOT, ease:FlxEase.sineIn, onComplete:function(_)
			{
				FlxSpriteUtil.flicker(heroSkull, 2, 0.1, true, true);
				FlxTween.tween(heroSkull, {alpha:0}, .2, {type:FlxTweenType.ONESHOT, ease:FlxEase.sineOut, startDelay:1.8});
			}
		});

		FlxTween.tween(heroSkull, {y:HEROSTARTY - 16}, 2, {type:FlxTweenType.ONESHOT, ease:FlxEase.sineInOut, onComplete:function(_)
		{
			heroSkull.kill();
		}
														  });

	}

	public function showHeroDamage(Amount:Int):Void
	{
		heroDmgNo.text = Std.string(Amount);
		heroDmgNo.alpha = 0;
		heroDmgNo.reset(fightingHero.x + 8 - (heroDmgNo.width / 2), MONSTERSTARTY - 4);

		FlxTween.tween(heroDmgNo, {y:MONSTERSTARTY - heroDmgNo.height - 4, alpha:1}, .33, {
			type:FlxTweenType.ONESHOT, ease:FlxEase.backOut, onComplete:function(_)
			{
				FlxTween.tween(heroDmgNo, {alpha:0, y:MONSTERSTARTY - heroDmgNo.height}, .1, {
					startDelay: .5, type:FlxTweenType.ONESHOT, ease:FlxEase.circOut, onComplete:function(_)
					{
						heroDmgNo.kill();
					}
				});
			}
		});
	}
	public function showMonsterDamage(Amount:Int):Void
	{
		monstDmgNo.text = Std.string(Amount);
		monstDmgNo.alpha = 0;
		monstDmgNo.reset(fightingMonster.x - (monstDmgNo.width / 2), MONSTERSTARTY - 4);

		FlxTween.tween(monstDmgNo, {y:MONSTERSTARTY - monstDmgNo.height - 4, alpha:1}, .33, {
			type:FlxTweenType.ONESHOT, ease:FlxEase.backOut, onComplete:function(_)
			{
				FlxTween.tween(monstDmgNo, {alpha:0, y:MONSTERSTARTY - monstDmgNo.height}, .1, {
					startDelay: .5, type:FlxTweenType.ONESHOT, ease:FlxEase.circOut, onComplete:function(_)
					{
						monstDmgNo.kill();
					}
				});
			}
		});
	}

	public function giveScore(Amount:Int):Void
	{
		score+= Amount;
		scoreDisp.changeAmount(score);
	}

	private function pauseGame():Void
	{
		if (!ready)
			return;
		ready = false;
		Sounds.play("click", .2);
		openSubState(new PauseScreen(currentEnv, function() { ready = true; }));
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		
		
		if (!ready)
			return;

		selector.visible = false;

		if (FlxG.keys.anyJustReleased([ESCAPE, P]))
		{
			Sounds.play("click", .2);
			pauseGame();
			return;
		}
		
		#if debug
		

		if (FlxG.keys.anyJustReleased([F5]))
		{
			openSubState(new GameOver(true, score));
			return;
		}
		#end

		if (changingEnv)
			return;

		if (firstMatch)
		{
			refillTimer += elapsed;

		}

		if (swapping || castingSpell)
			return;

		if (doChangeEnv)
		{
			selector.visible = false;
			selected.visible = false;
			nextEnv();
			return;
		}

		if (refillTimer >= REFILL_TIME)
		{
			refillTimer -= REFILL_TIME;
			//changingEnv = true;
			swapping = true;
			fillWithNewBlocks();
			return;
		}

		for (b in blocks)
		{
			if (FlxG.mouse.overlaps(b) && b.alive && b.exists)
			{
				selector.visible = true;
				selector.x = b.x - 1;
				selector.y = b.y - 1;
				overlappingBlock = b.ID;
				break;
			}
		}

		if (selector.visible)
		{
			if (FlxG.mouse.justReleased)
			{
				Sounds.play("click", .2);

				if (selectedBlock != -1)
				{
					if (!trySwap(selectedBlock,overlappingBlock))
					{
						selectBlock(overlappingBlock);
					}
				}
				else
				{
					selectBlock(overlappingBlock);
				}

			}
		}

		if (swapping)
			return;

		doCombat(elapsed);

	}

	public function trySwap(From:Int, To:Int):Bool
	{
		var swapOK:Bool = false;
		var fromBlock:Block=null;
		var toBlock:Block=null;
		if (To == From || To == -1 || From == -1) return false;
		for (b in blocks)
		{
			if (b.ID == To)
				toBlock = b;
			else if (b.ID == From)
				fromBlock = b;
		}
		if (toBlock.y == fromBlock.y)
		{
			swapOK  = (toBlock.x == fromBlock.x - 10) || (toBlock.x == fromBlock.x + 10);
		}
		else if (toBlock.x == fromBlock.x)
		{
			swapOK  = (toBlock.y == fromBlock.y - 10) || (toBlock.y == fromBlock.y + 10);
		}
		if (swapOK)
		{
			doSwap(fromBlock, toBlock);
			return true;
		}
		return false;

	}

	public function doSwap(From:Block, To:Block):Void
	{
		selected.visible = selector.visible = false;
		swapping = true;
		selectedBlock  = -1;
		overlappingBlock = -1;

		Sounds.play("swap");
		
		FlxTween.linearMotion(To, To.x, To.y, From.x, From.y, .33, true, {type:FlxTweenType.ONESHOT, ease:FlxEase.circInOut});
		FlxTween.linearMotion(From, From.x, From.y, To.x, To.y, .33, true, {
			type:FlxTweenType.ONESHOT, ease:FlxEase.circInOut, onComplete:function(_)
			{
				combo = 1;
				newCombo = true;
				matchedPotion = false;
				findMatches();
			}
		});
	}

	public function selectBlock(ID:Int):Void
	{
		for (b in blocks)
		{
			if (!b.alive) continue;
			if (b.ID == ID)
			{
				selected.visible = true;
				selected.x = b.x-1;
				selected.y = b.y - 1;
				selectedBlock = b.ID;
				break;
			}
		}

	}

	public function addToTubes(X:Float, Y:Float, MonsterID:Int, Amount:Int, Bonus:Int, ?FromMeteor:Bool = false):Void
	{

		var whichT:Tube = null;
		for (t in tubes)
		{
			if (t.whichMonster == MonsterID)
			{
				whichT = t;
				break;
			}
		}
		if (whichT == null)
		{
			for (t in tubes)
			{
				if (t.whichMonster == -1)
				{
					whichT = t;
					whichT.whichMonster = MonsterID;
					break;
				}
			}
		}
		if (whichT != null)
		{
			
			var amount:Float = 0;
			var n:Float = 0;
			
			if (FromMeteor)
			{
				amount = Amount;
			}
			else
			{
				amount = Math.pow(Amount - 3, 2) + 1;
				
				
				
				
			}
			
			n = ((amount / 10) + (Bonus * .05)) * combo;
			
			showFloatingNumber(X, Y, Std.string((n * 100) + "%"));

			var amt:Float = whichT.fillAmount + n;
			
			giveScore(Std.int(n * 150));
			
			spawnJuice(X + 4, Y + 4, MonsterData.getFromID(MonsterID).color, whichT.x + 4, whichT.y + 12);

			if (amt >= 1)
			{
				var leftOver:Float = amt - 1;
				monsterQueue.push(MonsterID);
				whichT.fillAmount = leftOver;

				whichT.showSpawn();
				Counts.add("monsters_spawned", 1);
				Sounds.play("spawn");
			}
			else
				whichT.fillAmount = amt;
		}
	}

	public function showFloatingNumber(X:Float, Y:Float, Display:String):Void
	{
		var f:FloatingNumber = floatingNumbers.recycle(FloatingNumber);
		f.start(X, Y, Display);
		floatingNumbers.add(f);
	}

	public function countMatches(X:Float, Y:Float, ID:Int, ?XDir:Int = 0, ?YDir:Int = 0, ?Count:Int = 0):Int
	{
		var newX:Float = X + (10 * XDir);
		var newY:Float = Y - (10 * YDir);

		for (b in blocks)
		{

			if (b.x == newX && b.y == newY && b.alive)
			{
				if ((b.matchedX && XDir == 1) || (b.matchedY && YDir == 1))
				{
					// skip?
					break;
				}

				

				if ((b.isPotion && ID == -99) || b.animation.frameIndex == ID)
				{
					Count=countMatches(b.x, b.y, b.isPotion ? -99 : b.animation.frameIndex, XDir, YDir, Count+1);
					if (Count >= 2)
					{
						b.isMatched = true;
						if (XDir ==1)
							b.matchedX = true;
						else
							b.matchedY = true;
					}

				}
			}
		}
		return Count;
	}

	public function findMatches():Void
	{
		var matches:Array<MatchData> = [];
		swapping = true;
		anyMatches = false;
		numMatchesFound = 0;
		var counts:Int = 0;
		var matchedThisCombo:Bool = false;
		for (y in 0...8)
		{
			for (x in 0...8)
			{
				for (b in blocks)
				{
					if (b.x == SPAWNX + (10 * x) && b.y == SPAWNY - (10 * y) && b.alive)
					{
						if (!b.matchedX)
						{
							counts = countMatches(b.x, b.y, b.isPotion ? -99 : b.animation.frameIndex, 1, 0);
							
							if (counts >= 2)
							{
								b.isMatched = true;
								b.matchedX = true;
								
								matches.push({
									source: FlxPoint.get(b.x, b.y),
									whichMonster: b.animation.frameIndex,
									count: counts+1,
									potion: b.isPotion,
									skull: b.skull
								});
								anyMatches = true;
							}
						}
						break;
					}
				}

			}
		}

		for (x2 in 0...8)
		{
			for (y2 in 0...8)
			{

				for (b in blocks)
				{
					if (b.x == SPAWNX + (10 * x2) && b.y == SPAWNY - (10 * y2) && b.alive)
					{
						
						if (!b.matchedY)
						{
							counts = countMatches(b.x, b.y, b.isPotion ? -99 : b.animation.frameIndex, 0, 1, 0);
							
							if (counts >= 2)
							{
								b.isMatched = true;
								b.matchedY = true;
								
								matches.push({
									source: FlxPoint.get(b.x, b.y),
									whichMonster: b.animation.frameIndex,
									count: counts+1,
									potion: b.isPotion,
									skull: b.skull
								});
								anyMatches = true;
							}
						}
						break;
					}
				}
			}
		}

		var matchCount:Int = -1;
		for (m in matches)
		{
			if (!m.skull && !m.potion)
			{
				matchCount++;
			}
		}
		
		for (m in matches)
		{
			if (!changingEnv && !matchedThisCombo)
			{
				matchedThisCombo = true;
				if (newCombo)
					newCombo = false;
				else
				{
					combo++;
					comboDisp.show(combo);
				}
			}
			
			if (m.potion)
			{
				matchedPotion = true;
				giveScore(10 * counts * combo);
				Sounds.play("potion", .66);
			}
			else if (m.skull)
			{
				giveScore(2 * counts * combo);
				Sounds.play("skull_crush", .33);
			}
			else
			{
				addToTubes(m.source.x, m.source.y, m.whichMonster, m.count, matchCount);
				//giveScore(MonsterData.getFromID(m.whichMonster).hp * m.count * combo);
				Sounds.play("match",.66);
			}

		}
		
		destroyMatches();
	}

	public function spawnMonster():Bool
	{
		if (monsterQueue.length == 0)
		{
			return false;
		}

		var m:Int = monsterQueue.shift();
		currentMonster = m;
		thisMonster = MonsterData.getFromID(m);

		thisMonster.hp = thisMonster.hp;
		thisMonster.att = thisMonster.att;
		thisMonster.def = thisMonster.def;
		thisMonster.sdef = thisMonster.sdef;
		thisMonster.satt = thisMonster.satt;

		fightingMonster.animation.frameIndex = m;
		fightingMonster.x = MONSTERSTARTX;

		FlxTween.color(fightingMonster, .5, FlxColor.fromRGB(0,0,0,0), FlxColor.WHITE, {type:FlxTweenType.ONESHOT, ease:FlxEase.circInOut});
		FlxTween.tween(fightingMonster, {x:114}, .5, {
			type:FlxTweenType.ONESHOT, ease:FlxEase.circInOut, onComplete:function(_)
			{
				monsterReady = true;
			}
		});
		return true;

	}

	public function spawnPop(X:Float, Y:Float):Void
	{
		var p:Pop = null;
		p = pops.recycle(Pop);
		if (p == null)
			p = new Pop();
		p.start(X, Y);
		pops.add(p);
	}

	public function destroyMatches():Void
	{
		if (!anyMatches)
		{
			if (changingEnv)
			{
				finishNewEnv();
			}
			else
			{
				reset();
			}

			return;
		}

		firstMatch = true;
		cauldron.animation.play("burst", true);

		for (b in blocks)
		{
			if (b.isMatched && b.alive)
			{
				spawnPop(b.x, b.y);
			}
		}

		FlxTween.num(1, 0.001, .33, {ease:FlxEase.circInOut, type:FlxTweenType.ONESHOT, onComplete:function(_)
			{
				for (b in blocks)
				{
					if (b.isMatched && b.alive)
					{
						if (b.matchedX && b.matchedY && (!b.skull && !b.isPotion))
						{
							Sounds.play("potion", .66);
							b.matchedX = b.matchedY = b.isMatched = false;
							b.isPotion = true;
							b.scale.set(1, 1);
							b.alpha = 1;
						}
						else
							b.kill();
					}
				}

				checkGravity();
			}
		}, shrinkMatches);
	}

	public function checkGravity():Void
	{
		var anyFall:Bool = false;

		for (y in 1...8)
		{
			for (x in 0...8)
			{
				for (b in blocks)
				{
					if (!b.alive) continue;

					if (b.x == SPAWNX + (10 * x) && b.y == SPAWNY - (10 * y))
					{
						if (!hasNeighborBelow(b.x, b.y))
						{
							anyFall = true;
							b.falling = true;
						}
					}
				}
			}
		}
		if (anyFall)
		{
			Sounds.play("drop");
			FlxTween.num(0, 10, .1, {ease:FlxEase.cubeOut, type:FlxTweenType.ONESHOT, onComplete:function(_)
				{
					for (b in blocks)
					{
						if (b.falling)
						{
							b.falling = false;
						}
					}
					checkGravity();
				}
			}, function(Value:Float)
			{
				for (b in blocks)
				{
					if (b.falling)
						b.y = b.baseY + Value;
				}
			});
		}
		else
		{

			//everything has fallen - shift empty columns to the right if any are empty
			if (changingEnv)
				findMatches();
			else
				condenseEmptyColumns();

			//
		}

	}

	public function condenseEmptyColumns():Void
	{
		var hasOne:Bool = false;
		var hasAny:Bool = false;

		for (x in 0...8)
		{
			if (hasAny) continue;

			hasOne = false;
			for (b in blocks)
			{
				if (!b.alive) continue;
				if (b.x == SPAWNX + (10 * (7-x)) && b.y == SPAWNY)
				{
					hasOne = true;
					break;
				}
			}
			if (!hasOne)
			{
				hasAny = true;
				if (x < 7)
				{
					for (b in blocks)
					{
						if (b.alive && b.x < SPAWNX + (10 * (7 - x)))
						{
							b.shifting = true;
						}
					}

					FlxTween.num(0, 10, .33, {ease:FlxEase.cubeInOut, type:FlxTweenType.ONESHOT, onComplete:function(_)
					{
						for (b in blocks)
						{
							if (b.shifting)
							{
								b.shifting = false;
							}
						}
						fillNewColumn();
					}
											 }, function(Value:Float)
					{
						for (b in blocks)
						{
							if (b.shifting)
								b.x = b.baseX + Value;
						}
					});
				}
				else
				{
					fillNewColumn();

				}
			}
		}
		if (!hasAny)
		{
			findMatches();
		}
	}

	public function hasNeighborBelow(X:Float, Y:Float):Bool
	{
		for (b in blocks)
		{
			if (!b.alive) continue;
			if (b.x == X && b.y == Y + 10)
			{

				return !b.falling;
			}

		}
		return false;
	}

	public function shrinkMatches(Value:Float):Void
	{
		for (b in blocks)
		{
			if (b.isMatched)
				b.scale.set(Value, Value);
		}
	}

	public function reset():Void
	{
		swapping = false;
		changingEnv = false;
		combo = 1;
		newCombo = true;
		if (matchedPotion)
		{
			castingSpell = true;
			Sounds.play("spell_select");
			openSubState( new SpellChoice(returnFromSpellChoice));
		}

	}

}

typedef MatchData = {
	var source:FlxPoint;
	var whichMonster:Int;
	var count:Int;
	var potion:Bool;
	var skull:Bool;
}