import sys.thread.Lock;
import sys.thread.Mutex;
import sys.thread.Thread;

class DesktopOnlineConcurrencyTest {
    static var checks=0;
    static function check(ok:Bool,label:String):Void {checks++;if(!ok)throw label;}
    static function wait(lock:Lock,label:String):Void {check(lock.wait(5),label+" terminates within five seconds");}
    static function main():Void {
        var mutex=new Mutex();
        var entered=new Lock();
        var release=new Lock();
        var finished=new Lock();
        var producersDone=new Lock();
        var attempts:Array<String>=[];
        var accepted=0;
        var rejected=0;
        var active=0;
        var maximum=0;
        var workers=0;
        var gateTimedOut=false;
        var queue=new DesktopOnlineDispatcher(payload->{
            mutex.acquire();
            active++;
            if(active>maximum)maximum=active;
            attempts.push(payload);
            mutex.release();
            if(payload=="uncertain") {
                entered.release();
                var opened=release.wait(5);
                mutex.acquire();gateTimedOut=!opened;mutex.release();
            } else Sys.sleep(0.001);
            mutex.acquire();active--;mutex.release();
            if(payload=="uncertain")throw "simulated uncertain network insertion";
        },job->{
            mutex.acquire();workers++;mutex.release();
            Thread.create(()->{job();finished.release();});
        },8);
        check(queue.offer("uncertain"),"first event accepted");
        wait(entered,"real worker enters blocked sender");
        for(producer in 0...4) {
            var id=producer;
            Thread.create(()->{
                for(i in 0...20) {
                    var result=queue.offer("producer-"+id+"-"+i);
                    mutex.acquire();if(result)accepted++;else rejected++;mutex.release();
                }
                producersDone.release();
            });
        }
        for(i in 0...4)wait(producersDone,"producer "+i);
        mutex.acquire();
        var acceptedSnapshot=accepted;var rejectedSnapshot=rejected;var workersSnapshot=workers;
        mutex.release();
        check(acceptedSnapshot==7 && rejectedSnapshot==73,"concurrent offers enforce cap including blocked in-flight event");
        check(workersSnapshot==1,"concurrent offers schedule only one draining worker");
        release.release();
        wait(finished,"worker after sender exception");
        mutex.acquire();
        var attemptSnapshot=attempts.copy();var maxSnapshot=maximum;var activeSnapshot=active;var timeoutSnapshot=gateTimedOut;
        mutex.release();
        check(!timeoutSnapshot,"test releases sender before timeout");
        check(maxSnapshot==1 && activeSnapshot==0,"maximum simultaneous sends is exactly one and all sends finish");
        check(attemptSnapshot.length==8,"all and only accepted events attempted");
        var seen=new Map<String,Bool>();
        for(payload in attemptSnapshot)seen.set(payload,true);
        check([for(key in seen.keys())key].length==8,"no event retried after uncertain send");
        check(queue.offer("after-failure"),"fresh event accepted after exception and complete drain");
        wait(finished,"fresh worker");
        mutex.acquire();var finalAttempts=attempts.copy();var finalWorkers=workers;mutex.release();
        check(finalAttempts.length==9 && finalAttempts[8]=="after-failure" && finalWorkers==2,"new worker completes after prior worker terminates");

        var schedulerEntered=new Lock();
        var schedulerRelease=new Lock();
        var offerDone=new Lock();
        var recoveryDone=new Lock();
        var firstResult=true;
        var schedulingTimedOut=false;
        var scheduleCount=0;
        var delivered:Array<String>=[];
        var recovery=new DesktopOnlineDispatcher(payload->{mutex.acquire();delivered.push(payload);mutex.release();},job->{
            mutex.acquire();scheduleCount++;var count=scheduleCount;mutex.release();
            if(count==1) {
                schedulerEntered.release();
                var opened=schedulerRelease.wait(5);
                mutex.acquire();schedulingTimedOut=!opened;mutex.release();
                throw "simulated thread creation failure before scheduling";
            }
            Thread.create(()->{job();recoveryDone.release();});
        },2);
        Thread.create(()->{var result=recovery.offer("failed-start");mutex.acquire();firstResult=result;mutex.release();offerDone.release();});
        wait(schedulerEntered,"scheduler called by real producer thread");
        check(recovery.offer("queued-during-failure"),"concurrent offer can queue behind pending scheduler");
        check(!recovery.offer("overflow-during-failure"),"pending scheduler still enforces cap");
        schedulerRelease.release();
        wait(offerDone,"failed scheduler producer");
        mutex.acquire();var resultSnapshot=firstResult;var schedulingTimeoutSnapshot=schedulingTimedOut;mutex.release();
        check(!resultSnapshot && !schedulingTimeoutSnapshot,"scheduler exception returns false without hanging producer");
        check(recovery.offer("recovered"),"scheduler failure clears capacity and permits a new worker");
        wait(recoveryDone,"recovery worker");
        mutex.acquire();var deliveredSnapshot=delivered.copy();var scheduleSnapshot=scheduleCount;mutex.release();
        check(deliveredSnapshot.join(",")=="recovered" && scheduleSnapshot==2,"failed scheduling drops stale queue without retries");
        trace(checks+" real-thread telemetry concurrency assertions passed (no network)");
    }
}
