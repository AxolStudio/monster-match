package;

import io.newgrounds.NGLite.LoginOutcome;
import io.newgrounds.objects.events.Result.PingData;
#if (html5 && ng)
    import flixel.math.FlxPoint;
    import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
    import flixel.FlxSprite;
    import flixel.text.FlxText;
    import openfl.display.Bitmap;
    import openfl.display.BitmapData;
    import openfl.display.Loader;
    import openfl.geom.Point;
    import openfl.net.URLRequest;
    import io.newgrounds.objects.Medal;
    import io.newgrounds.crypto.Cipher;
    import io.newgrounds.NG;
    import flixel.graphics.frames.FlxTileFrames;
    import flixel.system.FlxAssets.FlxGraphicAsset;
    import flixel.FlxG;
    import flixel.util.FlxColor;
    import openfl.Assets;
    import flixel.util.FlxTimer;
    import io.newgrounds.objects.events.Response;
    import io.newgrounds.Call;

    class NGAPI
    {
    public static var APPID:String = Keys.keys.get("ngappid");

    public static var ENCKEY:String = Keys.keys.get("ngenckey");

    public static inline var SCOREBOARD_ID:Int = 10380;

    public static var loggedIn:Bool = false;

    public static var keepAlive:FlxTimer;

    public static function init():Void
    {
    #if debug
            trace(APPID, ENCKEY);
    #end

        if (APPID != "")
        {
            NG.createAndCheckSession(APPID);

    #if debug
                NG.core.verbose = true;
    #else
                NG.core.verbose = false;
    #end

            NG.core.setupEncryption(ENCKEY, AES_128, BASE_64);

    #if debug
                trace(NG.core.attemptingLogin);
    #end

            attemptLogin();
        }
    }

    private static function attemptLogin(?Callback:Null<Void->Void>):Void
    {
        if (NG.core.attemptingLogin)
        {
            /* a session_id was found in the loadervars, this means the user is playing on newgrounds.com
             * and we should login shortly. lets wait for that to happen
             */
    #if debug
                trace("attempting login");
    #end

            NG.core.onLogin.add(onNGLogin.bind(Callback));
        }
        else
        {
            /* They are NOT playing on newgrounds.com, no session id was found. We must start one manually, if we want to.
             * Note: This will cause a new browser window to pop up where they can log in to newgrounds
             */
    #if debug
                trace("request login");
    #end
            NG.core.requestLogin(function(outcome:LoginOutcome):Void
            {
                if (outcome.match(SUCCESS))
                    Callback();
            });
        }
    }

    private static function onNGLogin(Callback:Null<Void->Void>):Void
    {
    #if debug
            trace('logged in! user:${NG.core.user.name}');
    #end

        loggedIn = true;

        keepAlive = new FlxTimer().start(300, doPing, 1);

        NG.core.requestMedals((Err) ->
        {
    #if debug
                giveMedal(63809);
    #end
            if (Callback != null)
                Callback();
        });
    }

    private static function doPing(Timer:FlxTimer):Void
    {
        var call:Call<PingData> = NG.core.calls.gateway.ping();
        call.addResponseHandler(onPing);
        call.send();
    }

    private static function onPing(Response:Response<PingData>):Void
    {
        if (Response.success && Response.result.data.success)
        {
            keepAlive.reset(300);
        }
        else
            loggedIn = false;
    }

    public static function giveMedal(MedalID:Int):Void
    {
        if (!loggedIn)
        {
            attemptLogin(giveMedal.bind(MedalID));
            return;
        }
        var medal:Medal = NG.core.medals.get(MedalID);
        medal.onUnlock.add(showMedal.bind(medal));
    #if debug
            medal.sendDebugUnlock();
    #else
            if (!medal.unlocked)
            {
                medal.sendUnlock();
            }
    #end
    }

    private static function showMedal(NewMedal:Medal):Void
    {
    #if debug
            trace('${NewMedal.name} #${NewMedal.id} is worth ${NewMedal.value} points!');
            trace(NewMedal.icon);
    #end

        new NGMedalPopUp(NewMedal.name, NewMedal.icon);
    }

    public static function submitScore(Score:Int):Void
    {
        if (!loggedIn)
        {
            attemptLogin(submitScore.bind(Score));
            return;
        }
        NG.core.scoreBoards.loadList((_) ->
        {
            NG.core.scoreBoards.get(SCOREBOARD_ID).postScore(Score);
        });
    }
    }

    class NGMedalPopUp extends FlxTypedSpriteGroup<FlxSprite>
    {
    var top:FlxSpriteExt;
    var middle:FlxSpriteExt;
    var medal:FlxSpriteExt;
    var bg:FlxSpriteExt;
    var medal_name:FlxText;
    var points_text:FlxText;

    var medal_name_raw:String = "";
    var points_text_raw:String = "";

    var medal_text_dismiss:Bool = false;

    var medal_text_overflow:Bool = false;
    var medal_tick:Int = 0;

    var SOUND_IN:Bool = false;
    var SOUND_OUT:Bool = false;

    var animation_unpause_delay:Int = 0;

    var loader:Loader;
    var LOADED_MEDAL_IMAGE:Bool = false;

    var medal_text_max_length:Int = 10; // 14 for smaller letters but fetal fury is in all caps so...

    public function new(MedalName:String, MedalURL:String = "")
    {
        super();

        medal_name_raw = MedalName;

        medal_name = new FlxText((71 - 8) * .2, (35) * .2, (168 + 12), "");
        medal_name = Utils.formatText(medal_name, "center", FlxColor.WHITE, true, 22, "assets/fonts/DejaVuSans.ttf");

        points_text = new FlxText((171 + 21) * .2, (9) * .2, (50), "");
        points_text = Utils.formatText(points_text, "center", FlxColor.WHITE, true, 12, "assets/fonts/DejaVuSans.ttf");
        points_text.italic = true;
        points_text_raw = "100pts";

        construct_main_boxes(MedalURL);

        scrollFactor.set(0, 0);

        scale.set(.2, .2);

        updateHitbox();

        for (m in members)
            m.updateHitbox();

        setPosition((FlxG.width - width), (FlxG.height - (height) + 2));

        FlxG.state.add(this);
    }

    override function update(elapsed:Float)
    {
        if (loader != null)
        {
            if (loader.numChildren > 0 && !LOADED_MEDAL_IMAGE)
            {
                medal.makeGraphic(50, 50, FlxColor.WHITE);
                var bmp:BitmapData = cast(loader.getChildAt(0), Bitmap).bitmapData;
                var m_bmp:BitmapData = medal.graphic.bitmap;
                medal.graphic.bitmap.copyPixels(bmp, m_bmp.rect, new Point());
                LOADED_MEDAL_IMAGE = true;
            }
        }
        medal_text_manager();
        points_text_manager();
        sound_manager();
        medal.visible = top.animation.frameIndex >= 15 && top.animation.frameIndex <= 42;
        if (top.animation.finished)
            kill();
        super.update(elapsed);
    }

    function construct_main_boxes(MedalURL:String)
    {
        top = new FlxSpriteExt();
        middle = new FlxSpriteExt();
        bg = new FlxSpriteExt();

        top.loadGraphic(GraphicsCache.loadGraphic("assets/images/ng_medal_popup_A.png"), true, 250, 72);
        middle.loadGraphic(GraphicsCache.loadGraphic("assets/images/ng_medal_popup_B.png"), true, 250, 72);
        bg.loadGraphic(GraphicsCache.loadGraphic("assets/images/ng_medal_popup_C.png"), true, 250, 72);

        for (sprite in [top, middle, bg])
            sprite.animAddPlay("popup", "0t30,31h36,32t51", 36, false);

        medal = new FlxSpriteExt(10 * .2, 10 * .2);
        medal.visible = false;

        medal.loadGraphic(GraphicsCache.loadGraphic("assets/images/no_medal.png"));

        if (MedalURL != "")
        {
            loader = new Loader();
            loader.load(new URLRequest(MedalURL));
        }

        add(bg);
        add(medal);
        add(medal_name);
        add(points_text);
        add(middle);
        add(top);
    }

    function medal_text_manager()
    {
        medal_name.visible = top.animation.frameIndex > 15;
        medal_text_dismiss = top.animation.frameIndex > 31;
        if (!medal_name.visible)
            return;
        if (!medal_text_dismiss)
        {
            medal_tick++;
            if (medal_name_raw.length > 0)
            {
                if (medal_name.text.length < medal_text_max_length && !medal_text_overflow)
                {
                    medal_name.text = medal_name.text + medal_name_raw.charAt(0);
                    medal_name_raw = medal_name_raw.substr(1);
                }
                else
                {
                    medal_text_overflow = true;
                    if (medal_tick > 60 && medal_name.text.length > 0 && medal_tick % 4 == 0)
                    {
                        medal_name.text = medal_name.text.substr(1);
                        medal_name.text = medal_name.text + medal_name_raw.charAt(0);
                        medal_name_raw = medal_name_raw.substr(1);
                        if (medal_name_raw.length > 1)
                        {
                            animation_unpause_delay = 15;
                            for (sprite in [top, middle, bg])
                                sprite.animation.pause();
                        }
                    }
                }
            }
        }
        else
        {
            if (medal_name.text.length > 0)
            {
                medal_name.text = medal_name.text.substr(0, medal_name.text.length - 1);
            }
            else
            {
                medal_name.alpha = 0;
            }
        }
        animation_unpause_delay--;
        if (animation_unpause_delay == 0)
            for (sprite in [top, middle, bg])
                sprite.animation.resume();
    }

    function points_text_manager()
    {
        points_text.visible = medal_name.visible;
        if (!points_text.visible)
            return;
        if (!medal_text_dismiss)
        {
            if (points_text_raw.length > 0)
            {
                points_text.text = points_text.text + points_text_raw.charAt(0);
                points_text_raw = points_text_raw.substr(1);
            }
        }
        else
        {
            if (points_text.text.length > 0)
            {
                points_text.text = points_text.text.substr(0, points_text.text.length - 1);
            }
            else
            {
                points_text.alpha = 0;
            }
        }
    }

    function sound_manager()
    {
        if (!SOUND_IN && top.animation.frameIndex >= 5)
        {
            // oundPlayer.play_sound("assets/images/ng_medal_GET.ogg");
            Sounds.play("ng_medal_GET", .5);
            SOUND_IN = true;
        }
        if (!SOUND_OUT && top.animation.frameIndex >= 47)
        {
            Sounds.play("ng_medal_GOT", .5);
            SOUND_OUT = true;
        }
    }
    }

    /**
     * Extends FlxSprite with a bunch of useful stuff, mostly for animations
     */
    class FlxSpriteExt extends FlxSprite
    {
    /**Defined types of this, can be attributes and special effects and such*/
    var types:Array<String> = [];

    /**Animations that auto link when an animation is over*/
    var animationLinks:Array<Array<String>> = [];

    /**The previous anim played*/
    var lastAnim:String = "";

    var hitboxOverritten:Bool = false;

    /**logic state*/
    var state:String = "";

    /**simple tick**/
    var tick:Int = 0;

    /**Previous frame of animation**/
    var prevFrame:Int = 0;

    /**Was the last frame and current frame different?**/
    var isOnNewFrame:Bool = false;

    public function new(?X:Float, ?Y:Float, ?SimpleGraphic:FlxGraphicAsset)
    {
        super(X, Y, SimpleGraphic);
    }

    override function update(elapsed:Float)
    {
        isOnNewFrame = animation == null ? false : prevFrame != animation.frameIndex;
        prevFrame = animation == null ? 0 : animation.frameIndex;

        super.update(elapsed);
    }

    /***Loads the Image AND Animations from an AnimationSet***/
    public function loadAllFromAnimationSet(image:String, unique:Bool = false, autoIdle:Bool = true):Bool
    {
        var animSet:AnimSetData = Lists.getAnimationSet(image);

        if (animSet == null)
            return false;

        var animWidth:Float = animSet.dimensions.x;
        var animHeight:Float = animSet.dimensions.y;

        var fullPath:String = animSet.path + "/" + animSet.image + ".png";

        loadGraphic(fullPath);

        if (animWidth == 0)
            animWidth = graphic.width / (animSet.maxFrame + 1);
        if (animHeight == 0)
            animHeight = graphic.height;

        // debug(fullPath, animWidth, animHeight);

        if (animSet.offset.x != -999)
            offset.x = animSet.offset.x;
        if (animSet.offset.y != -999)
            offset.y = animSet.offset.y;

        frames = FlxTileFrames.fromGraphic(graphic, FlxPoint.get(animWidth, animHeight));

        if (animSet.hitbox.x != 0)
        {
            setSize(animSet.hitbox.x, animSet.hitbox.y);
            hitboxOverritten = true;
        }

        return loadAnimsFromAnimationSet(image, autoIdle);
    }

    public function loadAnimsFromAnimationSet(image:String, autoIdle:Bool = true):Bool
    {
        var animSet:AnimSetData = Lists.getAnimationSet(image);

        if (animSet == null)
            return false;

        for (set in animSet.animations)
        {
            animAdd(set.name, set.frames, set.fps, set.looping, false, false, set.linked);
            if (autoIdle && set.name == "idle")
                anim("idle");
        }

        // debug(getHitbox());

        return true;
    }

    /*
     * Shorthand for animation play
     */
    public function anim(s:String)
    {
        animation.play(s);
        lastAnim = s;
    }

    /*
     * Adds an animation using the Renaine shorthand
     */
    public function animAdd(animName:String, animString:String, ?fps:Int = 14, loopSet:Bool = true, flipXSet:Bool = false, flipYSet:Bool = false,
            animationLink:String = "")
    {
        animation.add(animName, Utils.anim(animString), fps, loopSet, flipXSet, flipYSet);
        if (animationLink.length > 0)
            addAnimationLink(animName, animationLink);
    }

    /*
     * Adds an animation using the Renaine shorthand and immediately plays it
     */
    public function animAddPlay(animName:String, animString:String, fps:Int = 14, loopSet:Bool = true, flipXSet:Bool = false, flipYSet:Bool = false,
            animationLink:String = "")
    {
        animation.add(animName, Utils.anim(animString), fps, loopSet, flipXSet, flipYSet);
        animation.play(animName);
    }

    /*
     * Plays an animation if and only if it's not playing already.
     */
    public function animProtect(animation_name:String = ""):Bool
    {
        if (animation.name != animation_name)
        {
            anim(animation_name);
            return true;
        }
        return false;
    }

    /**
        Adds a linking animation when this animation ends, "from" must not be Looped!
        @param	from a non-looped anim
        @param	to another anim, doesn't matter if it's looped or not
    **/
    public function addAnimationLink(from:String, to:String)
    {
        animationLinks.push([from, to]);
    }

    /*add a type*/
    public function addType(type_to_add:String):Bool
    {
        if (!isType(type_to_add))
        {
            types.push(type_to_add);
            return true;
        }
        return false;
    }

    /*check if this is a type*/
    public function isType(type_to_check:String):Bool
    {
        return types.indexOf(type_to_check) > -1;
    }

    /**
     * Switch state
     * @param new_state new state
     * @param reset_tick reset tick? defaults to true, tick will reset on the state change
     */
    function sstate(new_state:String, reset_tick:Bool = true)
    {
        if (reset_tick)
            tick = 0;
        state = new_state;
    }

    public function sstateAnim(s:String, resetInt:Bool = true)
    {
        sstate(s);
        anim(s);
    }

    function ttick()
    {
        tick++;
    }
    }

    class Utils
    {
    public static function XMLloadAssist(path:String):Xml
    {
        var text:String = Assets.getText(path);
        text = StringTools.replace(text, "/n", "&#xA;");
        text = StringTools.replace(text, "<&#xA;", "</n");
        return Xml.parse(text);
    }

    /*
     * Animation int array created using string of comma seperated frames
     * xTy = from x to y, takes r as optional form xTyRz to repeat z times
     * xHy = hold x, y times
     * ex: "0t2r2, 3h2" returns [0, 1, 2, 0, 1, 2, 3, 3, 3]
     */
    public static function animFromString(animString:String):Array<Int>
    {
        var frames:Array<Int> = [];
        var framesGroup:Array<String> = StringTools.replace(animString, " ", "").toLowerCase().split(",");
        if (framesGroup.length <= 0)
            framesGroup = [animString];
        for (f in framesGroup)
        {
            if (f.indexOf("h") > -1)
            { // hold/repeat frames
                var split:Array<String> = f.split("h"); // 0 = frame, 1 = hold frame multiplier so 1h5 is 1 hold 5 i.e. repeat 5 times
                frames = frames.concat(Utils.arrayR([Std.parseInt(split[0])], Std.parseInt(split[1])));
            }
            else if (f.indexOf("t") > -1)
            { // from x to y frames
                var repeats:Int = 1;
                if (f.indexOf("r") != -1)
                    repeats = Std.parseInt(f.substring(f.indexOf("r") + 1, f.length)); // add rInt at the end to repeat Int times
                f = StringTools.replace(f, "r", "t");
                for (i in 0...repeats)
                {
                    var split:Array<String> = f.split("t"); // 0 = first frame, 1 = last frame so 1t5 is 1 to 5
                    frames = frames.concat(Utils.array(Std.parseInt(split[0]), Std.parseInt(split[1])));
                }
            }
            else
            {
                frames.push(Std.parseInt(f));
            }
        }
        return frames;
    }

    /*
     * Alias for animFromString
     */
    public static function anim(animString:String):Array<Int>
    {
        return animFromString(animString);
    }

    public static function array(start:Int, end:Int):Array<Int>
    {
        var a:Array<Int> = [];
        if (start < end)
        {
            for (i in start...(end + 1))
            {
                a.push(i);
            }
        }
        else
        {
            for (i in (end + 1)...start)
            {
                a.push(i);
            }
        }
        return a;
    }

    /*
     * Creates repeating array that duplicates 'toRepeat', 'repeat' times
     */
    public static function arrayR(toRepeat:Array<Int>, repeats:Int):Array<Int>
    {
        var a:Array<Int> = [];
        for (i in 0...repeats)
        {
            for (c in toRepeat)
            {
                a.push(c);
            }
        }
        return a;
    }

    /**
     * Takes text and auto formats it
     * @param text the FlxText to format
     * @param alignment alignment i.e. 'center' 'left' 'right'
     * @param color text color
     * @param outline use an outline or not
     * @return FlxText formatted text
     */
    public static function formatText(text:FlxText, alignment:String = "left", color:Int = FlxColor.WHITE, outline:Bool = false, font_size:Int = 36,
            font:String = "assets/fonts/DejaVuSans.ttf"):FlxText
    {
        if (outline)
        {
            text.setFormat(font, font_size, color, alignment, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        }
        else
        {
            text.setFormat(font, font_size, color, alignment);
        }
    #if !flash
            text.x -= 1;
            text.y -= 1;
    #end
        return text;
    }
    }

    /***This an animation definition to be used with AnimSetData***/
    typedef AnimDef =
    {
    var name:String;
    var frames:String;
    var fps:Int;
    var looping:Bool;
    var linked:String;
    }

    typedef AnimSetData =
    {
    var image:String;
    var animations:Array<AnimDef>;
    var dimensions:FlxPoint;
    var offset:FlxPoint;
    var flipOffset:FlxPoint;
    var hitbox:FlxPoint;
    var maxFrame:Int;
    var path:String;
    }

    class Lists
    {
    /** All the animation data*/
    public static var animSets:Map<String, AnimSetData> = new Map<String, AnimSetData>();

    static var base_animation_fps:Int = 12;

    public static function init()
    {
        loadAnimationSets();
    }

    /***
     * Animation Set Loading and Usage
    ***/
    /**Loads all the animations from several xml files**/
    static function loadAnimationSets()
    {
        for (file in ["player_anims", "general_anims", "enemy_anims"])
        {
            loadAnimationSet("assets/data/anims/" + file + ".xml");
        }
    }

    static function loadAnimationSet(path:String)
    {
        var xml:Xml = Utils.XMLloadAssist(path);
        for (root in xml.elementsNamed("root"))
        {
            for (sset in root.elementsNamed("animSet"))
            {
                var allFrames:String = "";
                var animSet:AnimSetData = {
                    image: "",
                    animations: [],
                    dimensions: new FlxPoint(),
                    offset: new FlxPoint(-999, -999),
                    flipOffset: new FlxPoint(-999, -999),
                    hitbox: new FlxPoint(),
                    maxFrame: 0,
                    path: ""
                };

                for (aanim in sset.elementsNamed("anim"))
                {
                    var animDef:AnimDef = {
                        name: "",
                        frames: "",
                        fps: base_animation_fps,
                        looping: true,
                        linked: ""
                    };

                    if (aanim.get("fps") != null)
                        animDef.fps = Std.parseInt(aanim.get("fps"));
                    if (aanim.get("looping") != null)
                        animDef.looping = aanim.get("looping") == "true";
                    if (aanim.get("linked") != null)
                        animDef.linked = aanim.get("linked");
                    if (aanim.get("link") != null)
                        animDef.linked = aanim.get("link");

                    animDef.name = aanim.get("name");
                    animDef.frames = aanim.firstChild().toString();
                    allFrames = allFrames + animDef.frames + ",";

                    animSet.animations.push(animDef);
                }

                animSet.image = sset.get("image");
                animSet.path = StringTools.replace(sset.get("path"), "\\", "/");

                if (sset.get("x") != null)
                    animSet.offset.x = Std.parseFloat(sset.get("x"));
                if (sset.get("y") != null)
                    animSet.offset.y = Std.parseFloat(sset.get("y"));

                if (sset.get("width") != null)
                    animSet.dimensions.x = Std.parseFloat(sset.get("width"));
                if (sset.get("height") != null)
                    animSet.dimensions.y = Std.parseFloat(sset.get("height"));

                if (sset.get("hitbox") != null)
                {
                    var hitbox:Array<String> = sset.get("hitbox").split(",");
                    animSet.hitbox.set(Std.parseFloat(hitbox[0]), Std.parseFloat(hitbox[1]));
                }

                if (sset.get("flipOffset") != null)
                {
                    var flipOffset:Array<String> = sset.get("flipOffset").split(",");
                    animSet.flipOffset.set(Std.parseFloat(flipOffset[0]), Std.parseFloat(flipOffset[1]));
                }

                var maxFrame:Int = 0;

                allFrames = StringTools.replace(allFrames, "t", ",");

                for (frame in allFrames.split(","))
                {
                    if (frame.indexOf("h") > -1)
                        frame = frame.substring(0, frame.indexOf("h"));

                    var compFrame:Int = Std.parseInt(frame);

                    if (compFrame > maxFrame)
                    {
                        maxFrame = compFrame;
                    }
                }
                animSet.maxFrame = maxFrame;

                animSets.set(animSet.image, animSet);
            }
        }
    }

    public static function getAnimationSet(image:String):AnimSetData
    {
        return animSets.get(image);
    }
    }
#else
    class NGAPI {}
#end
