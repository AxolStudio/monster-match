/** Optional native platform features; never gate local gameplay or scores. */
class PlayServices {
    private static function call(method:String, signature:String, args:Array<Dynamic>):Void {
        #if android
        try {
            var fn = lime.system.JNI.createStaticMethod("com.axolstudio.monstermatch.PlayGamesBridge", method, signature, false, true);
            if (fn != null) Reflect.callMethod(null, fn, args);
        } catch (error:Dynamic) {
            trace("Play Games unavailable: " + Std.string(error));
        }
        #end
    }
    public static function unlockMedal(medal:Int):Void {
        var key = AchievementCatalog.key(medal);
        if (key != null) call("award", "(Ljava/lang/String;)V", [key]);
    }
    public static function submitScore(score:Int):Void { if (score >= 0) call("submitScore", "(I)V", [score]); }
    public static function beginRun():Void { call("beginRun", "()V", []); }
    public static function trackEvent(name:String, amount:Int):Void { call("trackEvent", "(Ljava/lang/String;I)V", [name, amount]); }
    public static function achievements():Void { call("showAchievements", "()V", []); }
    public static function leaderboard():Void { call("showLeaderboard", "()V", []); }
    public static function friends():Void { call("showFriends", "()V", []); }
    public static function cancelUi():Void { call("cancelUi", "()V", []); }
}
