import haxe.Json;
class DesktopOnlineSessionTest {
    static var checks=0;
    static final GUID="12345678-1234-4234-8234-123456789abc";
    static function check(ok:Bool,label:String):Void {checks++;if(!ok)throw label;}
    static function main():Void {
        var order:Array<String>=[];
        var generated=0;
        var s=new DesktopOnlineSession();
        check(!s.start("",()->{throw "read must not run";},_->{throw "persist must not run";},()->{throw "generate must not run";},()->{throw "start must not run";}),"empty game key disabled");
        check(!s.started && s.playerId=="","disabled session has no identity");
        check(s.payload("Launch",0,1700000000123)==null,"no payload before startup");
        check(s.start("existing-key",()->{order.push("read");return null;},id->{order.push("persist:"+id);return true;},()->{generated++;order.push("generate");return GUID;},()->{order.push("ready");}),"new identity starts");
        check(order.join("|")=="read|generate|persist:"+GUID+"|ready","identity flushed before ready callback");
        check(s.started && s.playerId==GUID && generated==1,"generated identity is active");
        var raw=s.payload("Game:Event:Launch",0,1700000000123);
        check(raw!=null,"ready session makes payload");
        var p:Dynamic=Json.parse(raw);
        check(p.game_id=="existing-key" && p.player_id==GUID,"payload identifies correct game/player");
        check(p.event_name=="Game:Event:Launch" && p.value==0 && p.event_time==1700000000,"payload retains event name/default and seconds");
        check(Reflect.fields(p).length==5,"payload contains only event contract fields");
        var names=Reflect.fields(p);names.sort(Reflect.compare);
        check(names.join(",")=="event_name,event_time,game_id,player_id,value","payload does not include account fields");
        check(s.start("existing-key",()->{throw "repeat read";},_->{throw "repeat persist";},()->{throw "repeat generate";},()->{throw "duplicate startup";}),"same game start is idempotent");
        check(!s.start("other-game",()->null,_->true,()->GUID,()->{}),"started session cannot be rebound");
        check(s.payload(" ",0,1700000000000)==null,"blank event rejected");
        check(s.payload("progress",Math.NaN,1700000000000)==null,"NaN value rejected");
        check(s.payload("progress",Math.POSITIVE_INFINITY,1700000000000)==null,"infinite value rejected");
        check(s.payload("progress",1,-1)==null && s.payload("progress",1,Math.NaN)==null,"invalid time rejected");
        var later:Dynamic=Json.parse(s.payload("progress",2.5,2200000000123));
        check(later.event_time==2200000000 && later.value==2.5,"timestamp avoids 2038 integer overflow");

        var existing=new DesktopOnlineSession();
        var writes=0;
        check(existing.start("existing-key",()->GUID.toUpperCase(),id->{writes++;return id==GUID;},()->{throw "valid stored ID regenerated";},()->{}),"existing GUID reused and normalized");
        check(existing.playerId==GUID && writes==1,"existing identity persistence verified");
        var corrupt=new DesktopOnlineSession();
        check(corrupt.start("existing-key",()->"broken-id",id->id==GUID,()->GUID,()->{}),"corrupt identity replaced");
        var failed=new DesktopOnlineSession();
        var ready=0;
        check(!failed.start("existing-key",()->null,_->false,()->GUID,()->{ready++;}),"flush failure prevents start");
        check(!failed.started && failed.playerId=="" && ready==0 && failed.payload("Launch",0,1)==null,"flush failure produces no event");
        check(failed.start("existing-key",()->GUID,_->true,()->GUID,()->{ready++;}),"later successful storage can start");
        check(ready==1,"only successful start calls ready");
        var readError=new DesktopOnlineSession();
        check(!readError.start("existing-key",()->{throw "storage read failed";},_->true,()->GUID,()->{}),"read exception fails closed");
        var writeError=new DesktopOnlineSession();
        check(!writeError.start("existing-key",()->null,_->{throw "storage write failed";},()->GUID,()->{}),"write exception fails closed");
        var invalidGenerated=new DesktopOnlineSession();
        check(!invalidGenerated.start("existing-key",()->null,_->true,()->"invalid",()->{}),"invalid generated ID rejected");
        var callbackError=new DesktopOnlineSession();
        var calls=0;
        check(callbackError.start("existing-key",()->GUID,_->true,()->GUID,()->{calls++;throw "transport startup failed";}),"optional transport failure cannot break initialized session");
        check(callbackError.start("existing-key",()->{throw "must not retry";},_->true,()->GUID,()->{calls++;}),"callback error does not retry ambiguous startup");
        check(calls==1,"startup callback attempted once");
        trace(checks+" telemetry session assertions passed");
    }
}
