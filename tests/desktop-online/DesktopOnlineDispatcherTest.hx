class DesktopOnlineDispatcherTest {
    static var checks=0;
    static function check(ok:Bool,label:String):Void {checks++;if(!ok)throw label;}
    static function main():Void {
        var jobs:Array<Void->Void>=[];
        var sent:Array<String>=[];
        var q=new DesktopOnlineDispatcher(s->sent.push(s),job->jobs.push(job));
        for(i in 0...64)check(q.offer("event-"+i),"default capacity accepts "+i);
        check(!q.offer("overflow"),"default cap refuses overflow");
        check(jobs.length==1 && sent.length==0,"only one asynchronous worker scheduled");
        jobs.shift()();
        check(sent.length==64 && sent[0]=="event-0" && sent[63]=="event-63","queue drains in insertion order");
        check(q.offer("after-drain") && jobs.length==1,"drained queue can schedule a new worker");
        jobs.shift()();
        check(sent[sent.length-1]=="after-drain","new worker sends subsequent event");

        var jobs2:Array<Void->Void>=[];
        var attempts:Array<String>=[];
        var failing=new DesktopOnlineDispatcher(s->{attempts.push(s);if(s=="bad")throw "network exception";},job->jobs2.push(job),3);
        check(failing.offer("first") && failing.offer("bad") && failing.offer("last"),"network fixture enqueued");
        jobs2.shift()();
        check(attempts.join(",")=="first,bad,last","network exception drops only current event and continues");
        check(jobs2.length==0,"network exception causes no retry scheduling");

        var jobs3:Array<Void->Void>=[];
        var reentrant:DesktopOnlineDispatcher=null;
        var accepted=false;
        var count=0;
        reentrant=new DesktopOnlineDispatcher(s->{count++;accepted=reentrant.offer("cannot-fit");},job->jobs3.push(job),1);
        check(reentrant.offer("in-flight"),"single-capacity accepts first");
        jobs3.shift()();
        check(!accepted && count==1 && jobs3.length==0,"in-flight event counts against capacity and cannot spawn parallel sender");

        var scheduled=0;
        var schedulingFailure=new DesktopOnlineDispatcher(_->{throw "never called";},_->{scheduled++;throw "thread unavailable";},2);
        check(!schedulingFailure.offer("not-scheduled"),"scheduler failure reported without throwing");
        check(!schedulingFailure.offer("new-attempt") && scheduled==2,"scheduler failure releases scheduling state");
        var invalid=false;try new DesktopOnlineDispatcher(_->{},_->{},0) catch(_:Dynamic)invalid=true;
        check(invalid,"zero capacity rejected");
        trace(checks+" telemetry dispatcher assertions passed");
    }
}
