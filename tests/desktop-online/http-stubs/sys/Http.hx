package sys;
class Http {
 public static var calls:Array<Dynamic>=[];
 public static var mode="ok";
 public var cnxTimeout:Float;
 public var onError:String->Void;
 public var onStatus:Int->Void;
 var url:String;var body:String;var headers:Map<String,String>=[];
 public function new(url:String){this.url=url;}
 public function setHeader(k:String,v:String):Void headers.set(k,v);
 public function setPostData(body:String):Void this.body=body;
 public function customRequest(post:Bool,out:haxe.io.Output,?socket:sys.net.Socket):Void {
  calls.push({url:url,post:post,body:body,headers:headers,timeout:cnxTimeout});
  if(mode=="throw")throw "simulated network failure";
  if(mode=="error"){onError("fake error");return;}
  onStatus(mode=="status"?500:200);
  if(mode=="large")out.prepare(65537);
  if(mode=="slow")Sys.sleep(3.05);
  var b=haxe.io.Bytes.ofString('{"status":200,"data":{"scores":{"scores":[]}}}');
  out.writeBytes(b,0,b.length);out.close();
 }
}
