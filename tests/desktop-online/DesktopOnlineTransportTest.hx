class DesktopOnlineTransportTest {
 static var count=0;
 static function check(ok:Bool,s:String){count++;if(!ok)throw s;}
 static function main(){
  var body=DesktopOnlineTransport.request("set/scores",'{"amount":123}');
  var r=sys.Http.calls[0];
  check(r.url=="https://axolstudio.com/api/2.0/set/scores" && r.post,"score endpoint and POST");
  check(r.timeout==3 && r.body=='{"amount":123}',"timeout and payload");
  check(r.headers.get("Content-Type")=="application/json; charset=utf-8","content-type");
  check(haxe.Json.parse(body).status==200,"bounded response returned");
  for(mode in ["throw","error","status","large","slow"]){
   sys.Http.mode=mode;var failed=false;
   try DesktopOnlineTransport.request("set/scores","{}") catch(_:Dynamic)failed=true;
   check(failed,"offline transport failure: "+mode);
  }
  check(sys.Http.calls.length==6,"one attempt per request and no retry");
  sys.Http.mode="ok";
  check(DesktopOnlineTransport.request("add/event","{}").length>0,"transport recovers after failures");
  var failed=false;try DesktopOnlineTransport.request("login/user","{}") catch(_:Dynamic)failed=true;
  check(failed && sys.Http.calls.length==7,"unrelated endpoints never requested");
  trace(count+" online transport assertions passed (fake HTTP, no network)");
 }
}
