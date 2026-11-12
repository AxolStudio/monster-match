#if desktop
import DesktopInput.DesktopFrame;
/** New or resumed menus require release before accepting any action. */
class DesktopFocus {
 public var index:Int;
 public var armed(default,null)=false;
 final count:Int;
 public function new(count:Int,initial:Int=0){if(count<1)throw "Empty focus";this.count=count;index=((initial%count)+count)%count;}
 #if !desktop_input_test
 public function paint(targets:Array<flixel.FlxSprite>):Void {
  for(i in 0...targets.length)targets[i].color=i==index?0xffffdd66:0xffffffff;
 }
 #end
 public function reset():Void {armed=false;}
 public function update(frame:DesktopFrame):Bool {
  if(!armed){armed=frame.neutral;return false;}
  var step=frame.dx!=0?frame.dx:frame.dy;
  index=(index+step+count)%count;
  return frame.accept&&!frame.back&&!frame.pause;
 }
}
#end
