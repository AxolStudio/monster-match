#if desktop
import sys.thread.Mutex;

/**
 * At most one draining worker and a bounded number of pending/in-flight events.
 * A scheduler accepts a job exactly once or throws before scheduling it.
 * A failed/uncertain send is dropped, never retried: the event endpoint has no deduplication.
 */
class DesktopOnlineDispatcher {
    final sender:String->Void;
    final schedule:(Void->Void)->Void;
    final capacity:Int;
    final mutex=new Mutex();
    final queue:Array<String>=[];
    var workerScheduled=false;
    var inFlight=false;

    public function new(sender:String->Void,schedule:(Void->Void)->Void,capacity:Int=64) {
        if(sender==null || schedule==null || capacity<1)throw "Invalid telemetry dispatcher configuration";
        this.sender=sender;this.schedule=schedule;this.capacity=capacity;
    }

    public function offer(payload:String):Bool {
        if(payload==null || payload=="")return false;
        var launch=false;
        mutex.acquire();
        if(queue.length+(inFlight?1:0)>=capacity) {
            mutex.release();
            return false;
        }
        queue.push(payload);
        if(!workerScheduled){workerScheduled=true;launch=true;}
        mutex.release();
        if(launch) {
            try schedule(drain) catch(_:Dynamic) {
                // Thread creation failed. Drop unsent work and let a future event try anew.
                mutex.acquire();
                queue.resize(0);
                workerScheduled=false;
                mutex.release();
                return false;
            }
        }
        return true;
    }

    function drain():Void {
        while(true) {
            mutex.acquire();
            if(queue.length==0) {
                workerScheduled=false;
                mutex.release();
                return;
            }
            var payload=queue.shift();
            inFlight=true;
            mutex.release();
            // Transport sees only an immutable string, never a Flixel object or save.
            try sender(payload) catch(_:Dynamic) {}
            mutex.acquire();
            inFlight=false;
            mutex.release();
        }
    }
}
#end
