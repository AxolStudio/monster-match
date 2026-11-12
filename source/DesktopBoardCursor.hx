#if desktop
import DesktopInput.DesktopFrame;
/** Cursor addresses stable spatial cells, never movable block object IDs. */
class DesktopBoardCursor {
 public var column(default,null)=0;
 public var row(default,null)=0;
 public var armed(default,null)=false;
 public function new(){}
 public function reset():Void {armed=false;}
 public function screenX(origin:Int):Int return origin+column*10;
 public function screenY(origin:Int):Int return origin-row*10;
 public function update(frame:DesktopFrame):Bool {
  if(!armed){armed=frame.neutral;return false;}
  if(frame.back||frame.pause)return false;
  column=Std.int(Math.max(0,Math.min(7,column+frame.dx)));
  row=Std.int(Math.max(0,Math.min(7,row-frame.dy)));
  return frame.accept;
 }
}
#end
