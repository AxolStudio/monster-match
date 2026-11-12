#if desktop
import flixel.FlxG;
import flixel.util.FlxSave;
/** Call only on engine main thread. Network worker receives serialized copies only. */
class DesktopOnline {
 static var client=new DesktopOnlineClient(request,job->sys.thread.Thread.create(job),()->Date.now().getTime());
 public static var ready(get,never):Bool;
 static function get_ready():Bool return client.ready;
 static function request(path:String,body:String):String {
  #if arcade_regression
  throw "Online disabled in regression";
  #else
  return DesktopOnlineTransport.request(path,body);
  #end
 }
 public static function start(save:FlxSave):Bool {
  #if arcade_regression
  return false;
  #else
  if(save==null || FlxG.game==null)return false;
  return client.start(DesktopOnlineConfig.gameKey(),
   ()->Std.isOfType(save.data.guid,String)?cast save.data.guid:null,
   guid->{save.data.guid=guid;return save.flush();},newGuid);
  #end
 }
 public static function sendEvent(name:String,value:Float=0):Void {try client.sendEvent(name,value) catch(_:Dynamic){}}
 public static function submitScore(amount:Int,initials:String):String return client.submitScore(amount,initials);
 public static function takeResult(token:String):Null<DesktopOnlineClient.DesktopOnlineResult> return client.takeResult(token);
 static function newGuid():String {
  var bytes=[for(_ in 0...16)Std.int(Math.random()*256)];bytes[6]=(bytes[6]&15)|64;bytes[8]=(bytes[8]&63)|128;
  var hex=[for(b in bytes)StringTools.hex(b,2)].join("").toLowerCase();
  return hex.substr(0,8)+"-"+hex.substr(8,4)+"-"+hex.substr(12,4)+"-"+hex.substr(16,4)+"-"+hex.substr(20,12);
 }
}
#end
