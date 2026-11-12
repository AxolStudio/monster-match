import flixel.FlxG;
import flixel.util.FlxSave;
@:access(DesktopOnline)
class DesktopOnlineFacadeTest {
 static var count=0;
 static function check(ok:Bool,s:String){count++;if(!ok)throw s;}
 static function main(){
  var jobs:Array<Void->Void>=[];var calls:Array<Dynamic>=[];
  function reset(){DesktopOnline.client=new DesktopOnlineClient((path,body)->{calls.push({path:path,body:haxe.Json.parse(body)});return '{"status":200,"data":{"scores":{"scores":[]}}}';},job->jobs.push(job),()->1000);}
  reset();var save=new FlxSave();FlxG.game=null;
  check(!DesktopOnline.start(save)&&jobs.length==0,"requires engine ready");
  FlxG.game={};FlxSave.failFlush=true;
  check(!DesktopOnline.start(save)&&jobs.length==0,"flush failure stays offline");
  FlxSave.failFlush=false;
  check(DesktopOnline.start(save)&&jobs.length==1,"successful durable startup");
  var guid=save.data.guid;
  check(Std.isOfType(guid,String)&&guid.length==36,"GUID stored in actual bound save field");
  check(FlxSave.log[FlxSave.log.length-1]=="flush","save flushed before dispatch");
  jobs.shift()();
  check(calls.length==1&&calls[0].body.player_id==guid,"launch uses persisted GUID");
  check(DesktopOnline.start(save)&&jobs.length==0,"repeat startup does not send duplicate launch");
  reset();check(DesktopOnline.start(save)&&save.data.guid==guid,"restart reuses stable identity");jobs.shift()();
  var token=DesktopOnline.submitScore(8,"ABC");check(DesktopOnline.takeResult(token)==null,"completion pending before worker");
  jobs.shift()();check(DesktopOnline.takeResult(token).status=="ok","main-thread polling receives worker result");
  DesktopOnline.sendEvent("game_completed",1);jobs.shift()();
  check(calls[calls.length-1].body.event_name=="game_completed","existing semantic events forwarded");
  trace(count+" online facade assertions passed (fake worker)");
 }
}
