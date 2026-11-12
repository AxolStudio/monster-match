package flixel.util;
class FlxSave {
    public static var saved:Map<String,Dynamic>=[];
    public static var log:Array<String>=[];
    public static var failBind=false;
    public static var failFlush=false;
    public static var throwBind=false;
    public var data:Dynamic={};
    public function new(){}
    public function bind(name:String,?path:String):Bool {
        log.push("bind:"+name+":"+path);
        if(throwBind)throw "storage unavailable";
        if(failBind)return false;
        var key=name+":"+path;
        if(!saved.exists(key))saved.set(key,{});
        data=saved.get(key);return true;
    }
    public function flush():Bool {log.push("flush");return !failFlush;}
    public function destroy():Void {}
}
