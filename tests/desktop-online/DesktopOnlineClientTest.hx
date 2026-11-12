class DesktopOnlineClientTest {
 static var count=0;
 static function check(ok:Bool,label:String){count++;if(!ok)throw label;}
 static function main(){
  var jobs:Array<Void->Void>=[];var sent:Array<Dynamic>=[];var persisted=false;var fails=false;
  var response='{"status":200,"data":{"scores":{"scores":[{"initials":"ABC","amount":"123"}]}}}';
  var c=new DesktopOnlineClient((path,body)->{check(persisted,"identity durable before network");sent.push({path:path,body:haxe.Json.parse(body)});if(fails)throw "uncertain insertion";return response;},job->jobs.push(job),()->2200000000123.0);
  var guid="01234567-89ab-4cde-8fab-0123456789ab";
  check(!c.start("",()->null,_->{throw "should not persist";},()->guid),"empty key disabled");
  var disabled=c.submitScore(12,"ABC");check(c.takeResult(disabled).status=="unavailable" && jobs.length==0,"disabled score returns offline completion");
  check(!c.start("test",()->null,_->false,()->guid),"flush failure disables network");
  check(c.start("test",()->null,_-> {persisted=true;return true;},()->guid),"durable startup succeeds");
  check(jobs.length==1,"launch schedules one worker");
  var token=c.submitScore(123,"ABC");
  check(jobs.length==1,"score uses shared single worker");jobs.shift()();
  check(sent.length==2 && sent[0].path=="add/event" && sent[1].path=="set/scores","launch then score wire order");
  check(sent[0].body.player_id==guid && sent[0].body.event_time==2200000000.0,"stable identity and seconds timestamp");
  check(sent[1].body.game_id=="test" && sent[1].body.amount==123 && sent[1].body.initials=="ABC","exact score payload");
  check(Reflect.fields(sent[1].body).length==3,"score payload contains no credentials or player data");
  var result=c.takeResult(token);check(result.status=="ok" && result.rows.length==1 && result.rows[0].amount==123,"valid remote rows sanitized");
  check(c.takeResult(token)==null,"completion consumed once");
  check(c.start("test",()->null,_->false,()->guid) && jobs.length==0,"startup idempotent without duplicate launch");
  fails=true;token=c.submitScore(5,"XYZ");jobs.shift()();check(c.takeResult(token).status=="failed" && jobs.length==0,"uncertain insertion failure never retried");
  fails=false;response='{"status":200,"data":{"scores":{"scores":[{"initials":"<script>","amount":1}]}}}';
  token=c.submitScore(5,"XYZ");jobs.shift()();check(c.takeResult(token).status=="failed","malformed rows do not reach UI");
  response='{"status":400}';token=c.submitScore(5,"XYZ");jobs.shift()();check(c.takeResult(token).status=="failed","API failure rejected");
  var before=sent.length;token=c.submitScore(-1,"XYZ");check(c.takeResult(token).status=="unavailable" && sent.length==before && jobs.length==0,"invalid score does not enqueue");
  response='{"status":200,"data":{"scores":{"scores":[]}}}';
  var tokens=[for(i in 0...70)c.submitScore(i,"ABC")];check(jobs.length==1,"burst retains one worker");jobs.shift()();
  check(sent.length==before+64,"bounded queue accepts at most64 pending requests");
  var completions=0;for(t in tokens)if(c.takeResult(t)!=null)completions++;
  check(completions<=16,"completion queue bounded even when UI leaves");
  trace(count+" desktop online assertions passed (fake transport)");
 }
}
