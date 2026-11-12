#if desktop
/** Durable anonymous identity and the event-only API wire format; no network or engine work. */
class DesktopOnlineSession {
    public var started(default,null)=false;
    public var playerId(default,null)="";
    var gameKey="";
    public function new(){}

    static function normalizedId(value:Null<String>):Null<String> {
        if(value==null)return null;
        var id=StringTools.trim(value).toLowerCase();
        return ~/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.match(id) ? id : null;
    }

    public function start(key:String,read:Void->Null<String>,persist:String->Bool,
        generate:Void->String,onStarted:Void->Void):Bool {
        if(key==null || StringTools.trim(key)=="")return false;
        if(started)return key==gameKey;
        var id:Null<String>;
        try {
            id=normalizedId(read());
            if(id==null)id=normalizedId(generate());
            if(id==null || !persist(id))return false;
        } catch(_:Dynamic) {return false;}
        gameKey=key;
        playerId=id;
        started=true;
        // Optional transport failure must not cause a duplicate, uncertain startup event.
        try onStarted() catch(_:Dynamic) {}
        return true;
    }

    public function payload(eventName:String,value:Float,epochMillis:Float):Null<String> {
        if(!started || eventName==null || StringTools.trim(eventName)=="" ||
            !Math.isFinite(value) || !Math.isFinite(epochMillis) || epochMillis<0)return null;
        return haxe.Json.stringify({
            event_time:Math.ffloor(epochMillis/1000),
            event_name:eventName,
            player_id:playerId,
            game_id:gameKey,
            value:value
        });
    }
}
#end
