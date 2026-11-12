#if desktop
/** Pure initials editor. A release gate prevents a held opening action submitting. */
class DesktopOnlineInitials {
 public var selected(default,null)=0;
 public final values:Array<Int>;
 final letters:Int;
 var focus=new DesktopFocus(1);
 public function new(values:Array<Int>,letters:Int){this.values=values.copy();this.letters=letters;}
 public function step(frame:DesktopInput.DesktopFrame):Bool {
  var accept=focus.update({dx:0,dy:0,accept:frame.accept,back:frame.back,pause:frame.pause,neutral:frame.neutral});
  if(!focus.armed)return false;
  if(frame.dy!=0)values[selected]=(values[selected]+frame.dy+letters)%letters;
  else if(frame.dx!=0)selected=(selected+frame.dx+3)%3;
  else if(frame.back)selected=Std.int(Math.max(0,selected-1));
  else if(accept){if(selected<2)selected++;else return true;}
  return false;
 }
}
#end
