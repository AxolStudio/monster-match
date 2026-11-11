package mobileintro;

import axollib.AxolAPI;
import axollib.Part;
import Globals;
import TitleState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.display.ShaderParameter;

using flixel.util.FlxSpriteUtil;

class MobileIntroState extends FlxTransitionableState
{
	private var baseColors:Array<FlxColor>;
	private var baseBitmapData:BitmapData;
	private var baseImage:FlxSprite;
	private var displayImage:FlxSprite;
	private var timer:Float = .25;
	private var shiftNo:Int = 0;
	private var timer2:Float = 0;
	private var timer3:Float = 1;

	private var strokeImage:FlxSprite;
	private var strokeBitmapData:BitmapData;
	private var strokeColors:Array<FlxColor>;

	private var madeinstlouis:FlxSprite;

	private var stage:Int = -1;

	private var parts:Array<Part>;

	private var checkedResolution:Bool = false;

	private var ohyeah:FlxSound;
	private var flixels:FlxSound;

	private var _times:Array<Float>;
	private var _sprite:FlxSprite;

	private var _text:FlxSprite;
	private var _curPart:Int = 0;

	private var _colors:Array<Int>;
	private var _functions:Array<Void->Void>;

	private var scale:Float;

	private var guy:Guy;
	private var sting:Guy;

	private var sparkles:FlxEmitter;
	private var skateBack:FlxSprite;

	private var exiting:Bool = false;

	private var barColors:Array<FlxColor> = [
		0xff000000,
		0xffe31d28,
		0xffed8c3d,
		0xfffcd234,
		0xff3e9965,
		0xff295167,
		0xff492245
	];
	private var bars:Array<FlxSprite> = new Array<FlxSprite>();

	private var dissolver:Dissolver = new Dissolver();
	private var dissolverText:Dissolver = new Dissolver();

	private var screenWidth:Int;
	private var screenHeight:Int;

	private var sparkleTimer:Float = 0;

	public function new()
	{
		bgColor = 0xff111111;

		super(null, new TransitionData(TransitionType.FADE, FlxColor.WHITE, .66));

		FlxG.autoPause = false;
		#if mouse
		FlxG.mouse.visible = false;
		#end
	}

	override public function destroy():Void
	{
		baseColors = [];
		baseBitmapData = FlxDestroyUtil.dispose(baseBitmapData);
		baseImage = FlxDestroyUtil.destroy(baseImage);
		displayImage = FlxDestroyUtil.destroy(displayImage);
		strokeImage = FlxDestroyUtil.destroy(strokeImage);
		strokeBitmapData = FlxDestroyUtil.dispose(strokeBitmapData);
		madeinstlouis = FlxDestroyUtil.destroy(madeinstlouis);
		flixels = FlxDestroyUtil.destroy(flixels);
		ohyeah = FlxDestroyUtil.destroy(ohyeah);
		strokeColors = [];
		if (parts != null)
		{
			for (p in parts)
			{
				p = null;
			}
			parts = null;
		}

		super.destroy();
	}

	private function preloadGameAssets():Void
	{


		FlxG.sound.cache("axollib/sounds/madeinstl.wav");

		FlxG.bitmap.add("axollib/images/hf-logo.png");
		FlxG.bitmap.add("axollib/images/haxeflixel-text.png");
		FlxG.bitmap.add("axollib/images/color-logo.png");
		FlxG.bitmap.add("axollib/images/color-stroke.png");
		FlxG.bitmap.add("axollib/images/madeinstlouis.png");
		FlxG.bitmap.add("assets/images/mobile-intro/ash.png");
		FlxG.bitmap.add("assets/images/mobile-intro/skate_back.png");
	}

	override public function create():Void
	{
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;

		preloadGameAssets();

		baseImage = new FlxSprite();
		baseImage.loadGraphic("axollib/images/color-logo.png", false);

		baseImage.screenCenter();

		scale = .15 * Math.min(FlxG.width, FlxG.height * 4 / 3) / baseImage.width;
		screenWidth = Std.int(FlxG.width / scale);
		screenHeight = Std.int(FlxG.height / scale);

		camera.setScale(scale, scale);

		strokeImage = new FlxSprite();
		strokeImage.loadGraphic("axollib/images/color-stroke.png", false);

		baseColors = [0xff492245, 0xff295167, 0xff3e9965, 0xfffcd234, 0xffed8c3d, 0xffe31d28];

		strokeColors = [0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000];

		// Add skateBack FIRST so it's behind everything
		skateBack = new FlxSprite();
		skateBack.loadGraphic("assets/images/mobile-intro/skate_back.png", false);
		var scaleRatio = camera.viewWidth / skateBack.width;
		skateBack.scale.set(scaleRatio, scaleRatio);
		skateBack.updateHitbox();
		skateBack.x = camera.viewLeft;
		skateBack.y = camera.viewBottom - 28 - (skateBack.height / 2) - 18;
		skateBack.alpha = 0;
		add(skateBack);

		// Add displayImage AFTER skateBack so it's in front
		displayImage = new FlxSprite();
		displayImage.makeGraphic(Std.int(baseImage.width), Std.int(baseImage.height + 50), 0x00000000);
		displayImage.screenCenter(FlxAxes.X);
		displayImage.y = camera.viewTop + 20 - 50;
		add(displayImage);

		madeinstlouis = new FlxSprite();
		madeinstlouis.loadGraphic("axollib/images/madeinstlouis.png", false);
		madeinstlouis.screenCenter(FlxAxes.X);
		madeinstlouis.y = displayImage.y + displayImage.height + 20;
		madeinstlouis.alpha = 0;
		add(madeinstlouis);

		baseBitmapData = baseImage.pixels.clone();
		strokeBitmapData = strokeImage.pixels.clone();

		parts = new Array<Part>();
		for (y in 0...baseBitmapData.height)
		{
			for (x in 0...baseBitmapData.width)
			{
				var c = baseBitmapData.getPixel32(x, y);
				if (c != 0 && c != 0xff000000)
				{
					var p = new Part(x, y + 50);
					parts.push(p);
				}
			}
		}

		displayImage.pixels.fillRect(displayImage.pixels.rect, 0x00000000);

		buildBars();

		FlxG.sound.volume = .66;

		flixels = new FlxSound();
		flixels.loadEmbedded(FlxAssets.getSoundAddExtension("flixel/sounds/flixel"));
		flixels.volume = .33;

		ohyeah = new FlxSound();

		ohyeah.loadEmbedded("axollib/sounds/madeinstl.wav");
		ohyeah.volume = .5;

		_times = [0.041, 0.184, 0.334, 0.495, 0.636];

		_colors = [0x3e9965, 0xfcd234, 0xe31d28, 0x492245, 0x295167];
		_functions = [drawGreen, drawYellow, drawRed, drawBlue, drawLightBlue];

		_sprite = new FlxSprite();
		_sprite.frames = GraphicsCache.loadAtlasFrames("axollib/images/hf-logo.png", "axollib/images/hf-logo.xml", false, "haxeflixel-logo", false);
		_sprite.animation.frameName = "green";
		_sprite.visible = false;

		_sprite.screenCenter(FlxAxes.XY);
		_sprite.x = Std.int(_sprite.x);
		_sprite.y = Std.int(_sprite.y);

		_text = new FlxSprite();
		_text.loadGraphic("axollib/images/haxeflixel-text.png", false);
		_text.scale.set(0.5, 0.5);
		_text.updateHitbox();
		_text.screenCenter(FlxAxes.X);

		_text.y = _sprite.y + _sprite.height + 5;

		_text.visible = false;

		add(_sprite);
		add(_text);

		new FlxTimer().start(.25, (_) ->
		{
			spreadBars();
		});

		new FlxTimer().start(1, (_) ->
		{
			addGuys();
			startFlixel();
		});

		var particleCount:Int = 200;
		sparkles = new FlxEmitter(0, 0, particleCount);

		var rainbowColors:Array<FlxColor> = [
			0xffff6b6b,
			0xffffa500,
			0xffffd93d,
			0xff6bcf7f,
			0xff4ecdc4,
			0xff95e1ff,
			0xffc77dff,
			0xffff6bda
		];

		var size = 1;
		var particle = null;
		for (i in 0...particleCount)
		{
			particle = new FlxParticle();
			particle.makeGraphic(size, size, rainbowColors[i % rainbowColors.length]);
			particle.exists = false;
			sparkles.add(particle);
		}

		FlxG.random.shuffle(sparkles.members);
		sparkles.launchMode = FlxEmitterMode.SQUARE;
		sparkles.width = 4;
		sparkles.height = 12;
		sparkles.velocity.set(-10, -15, 10, -2);
		sparkles.lifespan.set(0.1, 2.0);
		sparkles.alpha.set(1, 1, 0, 0);
		sparkles.solid = false;
		add(sparkles);

		super.create();
	}

	private function addGuys():Void
	{
		new FlxTimer().start(2.0, (_) ->
		{
			guy = new Guy("ash");
			guy.x = camera.viewLeft - guy.width - 60;
			guy.y = camera.viewBottom - (guy.height + 28);
			add(guy);
		});
	}

	private function spreadBars():Void
	{
		for (i in 0...Std.int(bars.length / 2))
		{
			var bar:FlxSprite = bars[i * 2];
			var offset:Float = (bars.length / 2) - 1 - i;

			FlxTween.tween(bar, {y: (bar.y - bar.height) + (offset * 2)}, .25, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut, startDelay: offset * .1});

			bar = bars[(i * 2) + 1];

			FlxTween.tween(bar, {y: (bar.y + bar.height) - (offset * 2)}, .25, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut, startDelay: offset * .1});
		}
	}

	private function closeBars():Void
	{
		for (i in 0...Std.int(bars.length / 2))
		{
			var bar:FlxSprite = bars[i * 2];

			FlxTween.tween(bar, {y: camera.viewTop + (camera.viewHeight / 2) - (bar.height)}, .25,
				{type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut, startDelay: i * .1});

			bar = bars[(i * 2) + 1];

			FlxTween.tween(bar, {y: camera.viewTop + (camera.viewHeight / 2)}, .25, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut, startDelay: i * .1});
		}
	}

	private function buildBars():Void
	{
		var bar:FlxSprite;
		for (i in 0...barColors.length)
		{
			bar = new FlxSprite();
			bar.makeGraphic(Std.int(camera.viewWidth), Std.int(camera.viewHeight / 2), barColors[barColors.length - 1 - i]);
			bar.x = camera.viewLeft;
			bar.y = camera.viewTop + (camera.viewHeight / 2) - bar.height;
			bars.push(bar);
			add(bar);

			bar = new FlxSprite();
			bar.makeGraphic(Std.int(camera.viewWidth), Std.int(camera.viewHeight / 2), barColors[barColors.length - 1 - i]);
			bar.x = camera.viewLeft;
			bar.y = camera.viewTop + (camera.viewHeight / 2);
			bars.push(bar);
			add(bar);
		}
	}

	private function startFlixel():Void
	{
		flixels.play();
		flixels.autoDestroy = false;

		for (time in _times)
		{
			new FlxTimer().start(time, timerCallback);
		}
	}

	function timerCallback(Timer:FlxTimer):Void
	{
		_functions[_curPart]();
		_text.color = _colors[_curPart];
		_curPart++;

		if (_curPart == 5)
		{
			Timer.start(2, (_) ->
			{
				FlxTween.tween(_sprite, {alpha: 0}, 0.2, {ease: FlxEase.quadOut});
				FlxTween.tween(_text, {alpha: 0}, 0.2, {ease: FlxEase.quadOut, onComplete: onComplete});
			}, -1);
		}
	}

	function drawGreen():Void
	{
		_sprite.visible = _text.visible = true;
		_sprite.animation.frameName = "green";
	}

	function drawYellow():Void
	{
		_sprite.animation.frameName = "yellow";
	}

	function drawRed():Void
	{
		_sprite.animation.frameName = "red";
	}

	function drawBlue():Void
	{
		_sprite.animation.frameName = "blue";
	}

	function drawLightBlue():Void
	{
		_sprite.animation.frameName = "light-blue";
	}

	function onComplete(Tween:FlxTween):Void
	{
		_sprite.kill();
		_text.kill();

		FlxTween.tween(skateBack, {alpha: 0.75}, 0.5, {type: FlxTweenType.ONESHOT, ease: FlxEase.sineIn});

		var t:FlxTimer = new FlxTimer().start(.25, (_) ->
		{
			startAxol();
		});
	}

	private function startAxol():Void
	{
		stage = 0;
		new FlxTimer().start(.55, function(_)
		{
			ohyeah.play();
			ohyeah.autoDestroy = false;
			new FlxTimer().start(0.8, (_) -> guy.startJump());
		});
	}

	private function colorStroke():Void
	{
		for (y in 0...Std.int(strokeBitmapData.height))
		{
			for (x in 0...Std.int(strokeBitmapData.width))
			{
				var color:FlxColor = strokeBitmapData.getPixel32(x, y);
				var c:Int = -1;
				if (color != 0 && color != 0xff000000)
				{
					for (j in 0...baseColors.length)
					{
						if (color == baseColors[j])
							c = j;
					}
				}
				if (c != -1)
				{
					if (y + 50 < displayImage.height)
						displayImage.pixels.setPixel32(x, y + 50, strokeColors[c]);
				}
			}
		}
		displayImage.dirty = true;
	}

	private function shiftColors():Void
	{
		if (shiftNo < 6)
		{
			strokeColors.pop();
			strokeColors.unshift(baseColors[shiftNo]);
			shiftNo++;
			colorStroke();
		}
		else if (shiftNo < 12)
		{
			strokeColors.pop();
			strokeColors.unshift(baseColors[5 - (shiftNo - 6)]);
			shiftNo++;
			colorStroke();
		}
		else if (shiftNo < 18)
		{
			strokeColors.pop();
			strokeColors.unshift(baseColors[0xff000000]);
			shiftNo++;
			colorStroke();
		}
		else if (shiftNo == 18)
		{
			shiftNo++;
			stage = 2;
		}
	}

	private function checkResolution():Void
	{
		checkedResolution = true;
	}

	private function updateSparkles(elapsed:Float):Void
	{
		if (guy == null || !guy.exists)
			return;

		sparkleTimer += elapsed;
		if (sparkleTimer >= 0.025)
		{
			sparkleTimer = 0;

			sparkles.setPosition(guy.x + 2, guy.y + 2);

			sparkles.start(true, 0, FlxG.random.int(7, 10));
		}
	}

	override public function update(elapsed:Float):Void
	{


		if (!checkedResolution)
			checkResolution();

		if (stage == 0)
		{
			timer -= elapsed;
			if (timer <= 0)
			{
				timer = .02;
				stage = 1;
			}
		}
		else if (stage == 1)
		{
			timer -= elapsed;
			if (timer <= 0)
			{
				timer = .01;

				displayImage.pixels.fillRect(displayImage.pixels.rect, 0x00000000);
				var anyNotDone:Bool = false;
				for (p in parts)
				{
					p.update();
					if (p.done)
					{
						displayImage.pixels.setPixel32(Std.int(p.x), Std.int(p.y), FlxColor.fromRGB(255, 255, 255, Std.int(p.alpha)));
					}
					else
					{
						displayImage.pixels.setPixel32(Std.int(p.x), Std.int(p.y), FlxColor.fromHSB(p.hue, 1, 1, Std.int(p.alpha)));
						anyNotDone = true;
					}
				}
				displayImage.dirty = true;
			}
		}
		else if (stage == 2)
		{
			stage = 3;
		}
		else if (stage == 3)
		{
			timer = 2.5;
			stage = 4;
			FlxTween.tween(madeinstlouis, {alpha: 1}, .5, {type: FlxTweenType.ONESHOT, ease: FlxEase.sineIn});
		}
		else if (stage == 4)
		{
			timer -= elapsed;
			if (timer <= 0)
			{
				// Don't fade anything out - just close bars over everything
				closeBars();

				new FlxTimer().start(1, (_) ->
				{
					FlxG.camera.fade(FlxColor.BLACK, .33, false, () ->
					{
						exitState();
					});
				});
				stage = 7; // Skip to end
			}
		}

		if (stage > 0)
		{
			if (timer3 > 0)
			{
				timer3 -= elapsed;
			}
			else if (shiftNo <= 18)
			{
				timer2 -= elapsed;
				if (timer2 <= 0)
				{
					timer2 = .025;
					shiftColors();
				}
			}
		}
		super.update(elapsed);
		updateSparkles(elapsed);
	}

	public function exitState():Void
	{
        Globals.initGame();
        FlxG.scaleMode = new CompactPixelScaleMode();
        FlxG.switchState(TitleState.new);
	}

}

class Guy extends FlxSprite
{
	private var jumpTimer:Float = 0;
	private var jumpDuration:Float = 1.2;
	private var jumpHeight:Float = 45;
	private var baseY:Float = 0;
	private var isJumping:Bool = false;
	private var jumpStarted:Bool = false;

	public function new(?Which:String = "ash"):Void
	{
		super();
		if (Which == "ash")
		{
			loadGraphic("assets/images/mobile-intro/ash.png", true, 16, 16, false, "ash");
			animation.add("skate", [3, 4], 8, true);
			animation.add("skatejump", [5, 6, 7, 8], 8, true);
			animation.play("skate");

			setFacingFlip(FlxDirectionFlags.LEFT, true, false);
			setFacingFlip(FlxDirectionFlags.RIGHT, false, false);
			facing = FlxDirectionFlags.RIGHT;
			velocity.x = 65;
		}
		else
		{
			loadGraphic("axollib/images/agents.png", true, 12, 12, false, "guy");
			animation.add("guy", [0, 1, 2, 3], 10, true);
			animation.add("sting", [4, 5, 6, 7], 10, true);
			animation.play(Which);
			setFacingFlip(FlxDirectionFlags.LEFT, true, false);
			setFacingFlip(FlxDirectionFlags.RIGHT, false, false);
			if (Which == "guy")
			{
				facing = FlxDirectionFlags.RIGHT;
				velocity.x = 65;
			}
			else
			{
				facing = FlxDirectionFlags.LEFT;
				velocity.x = -65;
			}
		}
	}

	public function startJump():Void
	{
		if (!isJumping && !jumpStarted)
		{
			jumpStarted = true;
			isJumping = true;
			jumpTimer = 0;
			animation.play("skatejump");

			FlxTween.tween(this, {y: baseY - jumpHeight}, 0.4, {
				ease: FlxEase.quadOut,
				onComplete: (_) ->
				{
					new FlxTimer().start(2.2, (_) ->
					{
						FlxTween.tween(this, {y: baseY}, 0.4, {
							ease: FlxEase.quadIn,
							onComplete: (_) ->
							{
								isJumping = false;
								animation.play("skate");
							}
						});
					});
				}
			});
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!isJumping)
		{
			baseY = y;
		}
	}
}

class Dissolver extends FlxShader
{
	public var percent(default, set):Float;

	public var fromColor(default, set):Null<FlxColor> = null;

	@:glFragmentSource('
#pragma header

uniform bool useFrom;
uniform vec4 fColor;
uniform float pct;


uniform vec2 u_resolution;

float rand (vec2 co) {
	return fract(sin(dot(co.xy ,vec2(12.9898,96.233))) * 43758.5453);
}

void main()
{
	vec2 initialPoint = openfl_TextureCoordv;

	vec2 point = ceil(initialPoint * openfl_TextureSize) / openfl_TextureSize;

	vec4 source = flixel_texture2D(bitmap, point);

	float alpha = step(pct, rand(point));

	if(source.a <= 0. || alpha <= 0.) discard;

	vec4 sample = source;

	if (useFrom)
	{
		sample = fColor;
	}

	gl_FragColor = vec4(sample.rgb, 1.);


}
    ')
	public function new():Void
	{
		super();
		data.useFrom.value = [false];
	}

	private function set_percent(Value:Float):Float
	{
		percent = FlxMath.bound(Value, 0, 1);

		data.pct.value = [percent];
		return percent;
	}

	private function set_fromColor(Value:FlxColor):FlxColor
	{
		fromColor = Value;
		if (fromColor == null)
		{
			data.useFrom.value = [false];
		}
		else
		{
			useFrom.value = [true];
			data.fColor.value = [
				fromColor.redFloat,
				fromColor.greenFloat,
				fromColor.blueFloat,
				fromColor.alphaFloat
			];
		}
		return fromColor;
	}
}
