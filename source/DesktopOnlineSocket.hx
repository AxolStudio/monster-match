#if (desktop && !arcade_regression)
import DesktopOnlineBudget.DesktopOnlineInput;
import DesktopOnlineBudget.DesktopOnlineOutput;
/** One synchronous worker; no watchdog or abandoned request thread.
    Native DNS resolution and TLS internals cannot be forcibly cancelled here.
    Deadline is checked at connect/read/write boundaries; each socket operation
    gets at most the remaining three-second budget. */
@:access(sys.net.Socket)
class DesktopOnlineSocket extends sys.ssl.Socket {
    final budget:DesktopOnlineBudget;
    var originalInput:haxe.io.Input;
    var originalOutput:haxe.io.Output;
    var closed=false;
    public function new(budget:DesktopOnlineBudget,rawLimit:Int=81920){
        super();this.budget=budget;
        originalInput=input;originalOutput=output;
        input=new DesktopOnlineInput(originalInput,budget,arm,rawLimit);
        output=new DesktopOnlineOutput(originalOutput,budget,arm);
    }
    function arm():Void {super.setTimeout(Math.min(3.0,budget.remaining()));}
    override public function setTimeout(seconds:Float):Void {super.setTimeout(Math.min(seconds,budget.remaining()));}
    override public function connect(host:sys.net.Host,port:Int):Void {arm();super.connect(host,port);budget.remaining();}
    override public function close():Void {
        if(closed)return;closed=true;
        // Native SSL close expects its original concrete stream classes.
        input=originalInput;output=originalOutput;super.close();
    }
}
#end
