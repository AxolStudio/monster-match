#if (desktop && !arcade_regression)
/** Fixed event/score endpoints only. No credentials, accounts, retry, or UI access. */
class DesktopOnlineTransport {
 public static function request(path:String,payload:String):String {
  if(path!="add/event" && path!="set/scores" && path!="get/scores")throw "Unsupported API operation";
  var http=new sys.Http("https://axolstudio.com/api/2.0/"+path);
  http.cnxTimeout=3.0;
  http.setHeader("Content-Type","application/json; charset=utf-8");http.setPostData(payload);
  var error=false;var status=0;
  http.onError=_->error=true;http.onStatus=value->status=value;
  var budget=new DesktopOnlineBudget(3.0);
  var limit=path=="add/event"?8192:65536;
  var response=new DesktopOnlineResponse(budget,limit);
  var socket=new DesktopOnlineSocket(budget,limit+16384);
  try http.customRequest(true,response,socket) catch(_:Dynamic)error=true;
  try socket.close() catch(_:Dynamic) {};
  if(error || status!=200)throw "Online request unsuccessful";
  return response.value();
 }
}
/** Bounded bytes only. 64 KiB for leaderboard JSON, 8 KiB for event acknowledgments. */
class DesktopOnlineResponse extends haxe.io.Output {
 final budget:DesktopOnlineBudget;
 final limit:Int;
 final bytes=new haxe.io.BytesBuffer();
 var count=0;
 public function new(budget:DesktopOnlineBudget,limit:Int){this.budget=budget;this.limit=limit;}
 override public function prepare(n:Int):Void {budget.remaining();if(n<0||n>limit)throw "Online response too large";}
 function accept(n:Int):Void {budget.remaining();if(n<0||n>limit-count)throw "Online response too large";count+=n;}
 override public function writeByte(value:Int):Void {accept(1);bytes.addByte(value);}
 override public function writeBytes(value:haxe.io.Bytes,pos:Int,len:Int):Int {accept(len);bytes.addBytes(value,pos,len);return len;}
 override public function close():Void {budget.remaining();}
 public function value():String {budget.remaining();return bytes.getBytes().toString();}
}
#end
