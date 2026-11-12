class DesktopOnlineInitialsTest {
 static var count=0;
 static function check(ok:Bool,s:String){count++;if(!ok)throw s;}
 static function f(dx=0,dy=0,a=false,b=false,n=false):DesktopInput.DesktopFrame return {dx:dx,dy:dy,accept:a,back:b,pause:false,neutral:n};
 static function main(){
  var edit=new DesktopOnlineInitials([0,1,2],38);
  check(!edit.step(f(0,0,true))&&edit.selected==0,"opening accept blocked");
  edit.step(f(0,0,false,false,true));
  edit.step(f(0,-1));check(edit.values[0]==37,"up wraps initials");
  edit.step(f(0,1));check(edit.values[0]==0,"down wraps initials");
  edit.step(f(-1));check(edit.selected==2,"left wraps slot");
  edit.step(f(1));check(edit.selected==0,"right wraps slot");
  check(!edit.step(f(0,0,true))&&edit.selected==1,"accept advances first slot");
  check(!edit.step(f(0,0,true))&&edit.selected==2,"accept advances second slot");
  check(edit.step(f(0,0,true)),"accept final slot submits");
  edit.step(f(0,0,false,true));check(edit.selected==1,"back selects prior slot without leaving gameover");
  trace(count+" desktop initials assertions passed");
 }
}
