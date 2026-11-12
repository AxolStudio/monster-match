import DesktopOnlineBudget.DesktopOnlineSink;
import DesktopOnlineBudget.DesktopOnlineInput;
import DesktopOnlineBudget.DesktopOnlineOutput;
class DesktopOnlineBudgetTest {
    static var checks=0;
    static function check(ok:Bool,label:String){checks++;if(!ok)throw label;}
    static function rejects(fn:Void->Void,label:String){var bad=false;try fn() catch(_:Dynamic)bad=true;check(bad,label);}
    static function main(){
        var now=0.0;
        var budget=new DesktopOnlineBudget(3,()->now);
        var sink=new DesktopOnlineSink(budget,8);
        rejects(()->sink.prepare(9),"oversize content-length rejected before allocation");
        var bytes=haxe.io.Bytes.alloc(9);
        check(sink.writeBytes(bytes,0,8)==8,"bounded sink accepts limit without retaining response");
        rejects(()->sink.writeByte(0),"chunked body cap cumulative");
        now=3;
        rejects(()->sink.close(),"slow final response rejected");
        now=0;
        var arms=0;
        var input=new DesktopOnlineInput(new haxe.io.BytesInput(bytes),budget,()->{budget.remaining();arms++;},8);
        check(input.readBytes(bytes,0,8)==8,"raw header/body bytes accepted up to limit");
        rejects(()->input.readByte(),"raw header cap cannot be bypassed by byte reads");
        check(arms==2,"each read arms timeout");
        var eof=new DesktopOnlineInput(new haxe.io.BytesInput(haxe.io.Bytes.alloc(0)),budget,()->{});
        var nonEof=false;try eof.readByte() catch(_:haxe.io.Eof){} catch(_:Dynamic)nonEof=true;
        check(nonEof,"premature EOF converted so HTTP header parser cannot spin");
        now=3.01;
        rejects(()->input.readByte(),"deadline prevents subsequent raw reads");
        now=0;
        var slow=new DesktopOnlineInput(new SlowInput(()->now=4),budget,()->{});
        rejects(()->slow.readByte(),"deadline checked immediately after slow read returns");
        now=0;
        var target=new haxe.io.BytesOutput();
        var out=new DesktopOnlineOutput(target,budget,()->{budget.remaining();});
        check(out.writeBytes(bytes,0,2)==2,"request write within deadline");
        now=4;rejects(()->out.writeByte(0),"late request write refused");
        check(target.length==2,"expired write never reaches transport");
        trace(checks+" transport budget assertions passed (fake I/O and clock)");
    }
}
private class SlowInput extends haxe.io.Input {
    final advance:Void->Void;
    public function new(advance:Void->Void){this.advance=advance;}
    override public function readBytes(b:haxe.io.Bytes,pos:Int,len:Int):Int {advance();b.set(pos,0);return 1;}
}
