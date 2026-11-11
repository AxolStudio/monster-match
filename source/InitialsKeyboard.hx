/** Native text entry is independent of optional online services. */
class InitialsKeyboard {
    public static function open(value:String):Bool {
        #if android
        try {
            lime.system.JNI.createStaticMethod("com.axolstudio.monstermatch.InitialsInput", "open", "(Ljava/lang/String;)V")(value);
            return true;
        } catch (error:Dynamic) { trace("Initials keyboard unavailable: " + error); }
        #end
        return false;
    }
    public static function takeResult():String {
        #if android
        return lime.system.JNI.createStaticMethod("com.axolstudio.monstermatch.InitialsInput", "takeResult", "()Ljava/lang/String;")();
        #else
        return null;
        #end
    }
    public static function close():Void {
        #if android
        lime.system.JNI.createStaticMethod("com.axolstudio.monstermatch.InitialsInput", "close", "()V")();
        #end
    }
}
