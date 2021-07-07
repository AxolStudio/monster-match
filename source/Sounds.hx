package;

import flixel.FlxG;
import flixel.system.FlxSound;
import lime.utils.AssetType;
import lime.utils.Assets;

using StringTools;

class Sounds
{
    private static var currentMusic:String;

    private static var sounds:Map<String, FlxSound>;

    private static var music:Map<String, String>;

    public static function preloadSounds():Void
    {
        sounds = new Map<String, FlxSound>();

        var s:FlxSound = null;
        var sName:String = "";

        for (a in Assets.list(AssetType.SOUND))
        {
            if (a.startsWith("assets/sounds/"))
            {
                s = new FlxSound().loadEmbedded(a, false, false);
                sName = a.substring("assets/sounds/".length, a.indexOf("."));

                sounds.set(sName, s);
            }
        }

        music = new Map<String, String>();
        for (a in Assets.list(AssetType.SOUND))
        {
            if (a.startsWith("assets/music/"))
            {
                // s = new FlxSound().loadEmbedded(a, false, false);
                sName = a.substring("assets/music/".length, a.indexOf("."));

                music.set(sName, a);
            }
        }
    }

    public static function play(SoundName:String, ?Volume:Float = 0.5):Void
    {
        var s:FlxSound = sounds.get(SoundName);
        if (s == null)
            throw "Unknown sound: '" + SoundName + "'";
        s.volume = Volume;
        s.play(true);
    }

    public static function playMusic(MusicName:String, ?Volume:Float = 0.5):Void
    {
        if (currentMusic != null)
        {
            if (currentMusic != MusicName)
            {
                FlxG.sound.music.fadeOut(.5, 0, function(_)
                {
                    switchMusicTo(MusicName, Volume);
                });
            }
        }
        else
        {
            switchMusicTo(MusicName, Volume);
        }
    }

    private static function switchMusicTo(MusicName:String, ?Volume:Float = 0.5):Void
    {
        var m:String = music.get(MusicName);
        if (m == null)
            throw "Unknown music: '" + (MusicName) + "'";
        FlxG.sound.playMusic(m, Volume, true);
        currentMusic = MusicName;
    }
}
