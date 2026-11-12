#if desktop
import DesktopInput.DesktopFrame;
/** Cursor addresses stable spatial cells, never movable block object IDs. */
class DesktopBoardCursor {
 public var column(default,null)=0;
 public var row(default,null)=0;
 public var armed(default,null)=false;
 public var pauseArmed(default,null)=false;
 public function new(){}
 public function reset():Void {armed=false;pauseArmed=false;}
 public function screenX(origin:Int):Int return origin+column*10;
 public function screenY(origin:Int):Int return origin-row*10;
 public static function modeAfterInput(current:Bool,frame:DesktopFrame,mouseActive:Bool,touchActive:Bool):Bool {
  if(mouseActive||touchActive)return false;
  return frame.dx!=0||frame.dy!=0||frame.accept ? true : current;
 }
 public function update(frame:DesktopFrame,busy:Bool=false):Bool {
  // Modal release gates pause; animations gate board actions only.
  if(!pauseArmed)pauseArmed=frame.neutral;
  if(busy){armed=false;return false;}
  if(!armed){armed=frame.neutral;return false;}
  if(frame.back||frame.pause)return false;
  column=Std.int(Math.max(0,Math.min(7,column+frame.dx)));
  row=Std.int(Math.max(0,Math.min(7,row-frame.dy)));
  return frame.accept;
 }
}
#end
