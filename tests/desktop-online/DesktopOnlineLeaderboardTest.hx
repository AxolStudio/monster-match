class DesktopOnlineLeaderboardTest {
 static var n=0;
 static function check(ok:Bool,s:String){n++;if(!ok)throw s;}
 static function main(){
  var local=[{initials:"LOC",amount:12}];
  var m=new DesktopOnlineLeaderboard(local,true,true);
  check(m.title()=="Local Hi Scores" && m.rows()[0].initials=="LOC","local shown immediately");
  check(m.status()=="Online: Pending","pending not delivery confirmation");
  check(m.update(0,{status:"ok",rows:[{initials:"WEB",amount:99}]}),"verified result updates display");
  check(m.title()=="Online Hi Scores" && m.rows()[0].initials=="WEB","remote rows actually displayed");
  check(m.status()=="Sent; Up/Down: Local","successful delivery shown only after ok");
  check(local[0].initials=="LOC" && m.toggle() && m.rows()[0].initials=="LOC","toggle preserves local records");
  var copy=m.rows();copy[0].initials="BAD";check(m.rows()[0].initials=="LOC","returned rows cannot mutate retained records");
  check(m.toggle() && m.rows()[0].initials=="WEB","remote view remains available");
  var late=new DesktopOnlineLeaderboard(local,true,true);
  check(late.update(10,null) && late.status()=="Online: Unavailable","timeout falls back without blocking");
  check(!late.update(0,{status:"ok",rows:[{initials:"WEB",amount:99}]}) && late.title()=="Local Hi Scores","late response ignored after timeout");
  var gone=new DesktopOnlineLeaderboard(local,true,true);gone.close();
  check(!gone.update(0,{status:"ok",rows:[]}) && gone.rows()[0].initials=="LOC","departed state ignores callback");
  var invalid:Array<Dynamic>=[{status:"failed",rows:[]},{status:"ok",rows:[{initials:"<bad>",amount:1}]},{status:"ok",rows:null},{status:"ok",rows:[{initials:12,amount:1}]},{status:"ok",rows:"not rows"}];
  for(result in invalid){
   var bad=new DesktopOnlineLeaderboard(local,true,true);bad.update(0,cast result);
   check(bad.status()=="Online: Unavailable" && bad.rows()[0].initials=="LOC" && !bad.toggle(),"failed/malformed result keeps local fallback");
  }
  var empty=new DesktopOnlineLeaderboard(local,true,false);empty.update(0,{status:"ok",rows:[]});
  check(empty.title()=="Online Hi Scores" && empty.rows().length==0,"empty verified leaderboard shown honestly");
  check(empty.status()=="Sent; local save failed","local persistence failure not hidden");
  trace(n+" leaderboard model assertions passed");
 }
}
