import DesktopInput.DesktopFrame;
class DesktopBoardCursorTest {
 static var count=0;
 static function check(v:Bool,s:String){count++;if(!v)throw s;}
 static function frame(dx=0,dy=0,accept=false,neutral=true):DesktopFrame return {dx:dx,dy:dy,accept:accept,neutral:neutral,back:false,pause:false};
 static function main(){
  var c=new DesktopBoardCursor();
  check(!c.update(frame(1,0,true,false)),"opening input ignored");check(c.column==0,"opening move ignored");
  c.update(frame());check(c.armed,"neutral arms");
  check(!c.update(frame(1,-1,false,false)),"move not accept");check(c.column==1&&c.row==1,"spatial axes");
  check(c.screenX(8)==18&&c.screenY(99)==89,"world position");
  check(c.update(frame(0,0,true,false)),"accept after neutral");
  for(i in 0...20)c.update(frame(1,-1,false,false));check(c.column==7&&c.row==7,"upper clamp");
  for(i in 0...20)c.update(frame(-1,1,false,false));check(c.column==0&&c.row==0,"lower clamp");
  c.update(frame(1,0,false,false));c.reset();check(!c.armed&&c.column==1,"modal reset preserves cell");
  check(!c.update(frame(0,0,true,false)),"held modal accept ignored");
  c.update(frame());check(c.update(frame(0,0,true,false)),"accept after modal release");
  var busy=new DesktopBoardCursor();busy.update(frame());
  var pauseFrame=frame(0,0,false,false);pauseFrame.pause=true;
  check(!busy.update(pauseFrame,true)&&busy.pauseArmed&&!busy.armed,"busy board still permits pause");
  check(!busy.update(frame(1,0,true,false),true)&&busy.column==0,"busy board ignores move and accept");
  busy.reset();busy.update(pauseFrame,true);check(!busy.pauseArmed,"modal held pause stays disarmed even busy");
  busy.update(frame(),true);check(busy.pauseArmed&&!busy.armed,"neutral rearms pause while board busy");
  check(!DesktopBoardCursor.modeAfterInput(true,frame(),false,true),"touch selects pointer mode without mouse");
  check(!DesktopBoardCursor.modeAfterInput(true,frame(),true,false),"mouse selects pointer mode");
  check(DesktopBoardCursor.modeAfterInput(false,frame(1,0,false,false),false,false),"controller reclaims focus");
  check(!DesktopBoardCursor.modeAfterInput(true,frame(1,0,true,false),false,true),"active touch wins simultaneous device pulse");
  trace(count+" board cursor assertions passed");
 }
}
