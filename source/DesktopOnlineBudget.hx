#if desktop
/** Monotonic I/O-boundary budget, not cancellation of native DNS/TLS calls. */
class DesktopOnlineBudget {
    final now:Void->Float;
    final deadline:Float;
    public function new(seconds:Float,?clock:Void->Float) {
        now=clock==null?haxe.Timer.stamp:clock;deadline=now()+seconds;
    }
    public function remaining():Float {
        var value=deadline-now();
        if(value<=0)throw "Telemetry request deadline exceeded";
        return value;
    }
}
class DesktopOnlineSink extends haxe.io.Output {
    final budget:DesktopOnlineBudget;
    final limit:Int;
    var count=0;
    public function new(budget:DesktopOnlineBudget,limit:Int=8192){this.budget=budget;this.limit=limit;}
    override public function prepare(n:Int):Void {budget.remaining();if(n<0||n>limit)throw "Telemetry response too large";}
    override public function writeByte(b:Int):Void {accept(1);}
    override public function writeBytes(b:haxe.io.Bytes,pos:Int,len:Int):Int {accept(len);return len;}
    function accept(n:Int):Void {budget.remaining();if(n<0||n>limit-count)throw "Telemetry response too large";count+=n;}
    override public function close():Void {budget.remaining();}
}
/** Bounds raw headers and body before sys.Http can buffer either. */
class DesktopOnlineInput extends haxe.io.Input {
    final source:haxe.io.Input;
    final before:Void->Void;
    final budget:DesktopOnlineBudget;
    final limit:Int;
    var count=0;
    public function new(source:haxe.io.Input,budget:DesktopOnlineBudget,before:Void->Void,limit:Int=16384){
        this.source=source;this.budget=budget;this.before=before;this.limit=limit;
    }
    override public function readByte():Int {var b=haxe.io.Bytes.alloc(1);readBytes(b,0,1);return b.get(0);}
    override public function readBytes(b:haxe.io.Bytes,pos:Int,len:Int):Int {
        before();if(count>=limit)throw "Telemetry raw response too large";
        var n:Int;
        try n=source.readBytes(b,pos,Std.int(Math.min(len,limit-count)))
        catch(_:haxe.io.Eof)throw "Telemetry response ended"; // sys.Http header parser otherwise swallows EOF forever.
        budget.remaining();
        if(n<=0)throw "Telemetry response made no progress";
        count+=n;return n;
    }
}
class DesktopOnlineOutput extends haxe.io.Output {
    final target:haxe.io.Output;
    final before:Void->Void;
    final budget:DesktopOnlineBudget;
    public function new(target:haxe.io.Output,budget:DesktopOnlineBudget,before:Void->Void){this.target=target;this.budget=budget;this.before=before;}
    override public function writeByte(b:Int):Void {before();target.writeByte(b);budget.remaining();}
    override public function writeBytes(b:haxe.io.Bytes,pos:Int,len:Int):Int {
        before();var n=target.writeBytes(b,pos,len);budget.remaining();if(n<=0)throw "Telemetry request made no progress";return n;
    }
}
#end
