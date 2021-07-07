package;

#if (html5 && ng)
    import io.newgrounds.objects.Medal;
    import io.newgrounds.crypto.Cipher;
    import io.newgrounds.crypto.EncryptionFormat;
    import io.newgrounds.NG;

    class NGAPI
    {
    public static var APPID:String = Keys.keys.get("ngappid");

    public static var ENCKEY:String = Keys.keys.get("ngenckey");

    public static var loggedIn:Bool = false;

    public static function init():Void
    {
        if (APPID != "")
        {
            NG.createAndCheckSession(APPID);

            NG.core.verbose = true;

            NG.core.initEncryption(ENCKEY, Cipher.RC4, EncryptionFormat.BASE_64);

            if (NG.core.attemptingLogin)
            {
                /* a session_id was found in the loadervars, this means the user is playing on newgrounds.com
                 * and we should login shortly. lets wait for that to happen
                 */

                NG.core.onLogin.add(onNGLogin);
            }
            else
            {
                /* They are NOT playing on newgrounds.com, no session id was found. We must start one manually, if we want to.
                 * Note: This will cause a new browser window to pop up where they can log in to newgrounds
                 */

                NG.core.requestLogin(onNGLogin);
            }
        }
    }

    private static function onNGLogin():Void
    {
        loggedIn = true;
    }

    // public static function beatGame(TimeTaken:Float):Void
    // {
    //     // check if they got the medal yet or not?
    //     if (loggedIn)
    //     {
    //         unlocks(TimeTaken);
    //     }
    //     else
    //     {
    //         NG.core.requestLogin(() ->
    //         {
    //             loggedIn = true;
    //             unlocks(TimeTaken);
    //         });
    //     }
    // }
    // private static function unlocks(TimeTaken:Float):Void
    // {
    //     NG.core.requestMedals(() ->
    //     {
    //         var medal:Medal = NG.core.medals.get(62196);
    //         if (!medal.unlocked)
    //         {
    //             medal.sendUnlock();
    //         }
    //     });
    //     NG.core.requestScoreBoards(() ->
    //     {
    //         NG.core.scoreBoards.get(SCOREBOARD_ID).postScore(Std.int(TimeTaken));
    //     });
    // }
    }
#end
