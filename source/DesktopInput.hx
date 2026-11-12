#if desktop
#if !desktop_input_test
import flixel.FlxG;
#end
/** Sample once in the active state. Edges do not repeat; directions do. */
class DesktopInput {
 static var state=new DesktopInputState();
 #if !desktop_input_test
 public static function sample(elapsed:Float):DesktopFrame {
  var x:Float=(FlxG.keys.anyPressed([RIGHT,D])?1:0)-(FlxG.keys.anyPressed([LEFT,A])?1:0);
  var y:Float=(FlxG.keys.anyPressed([DOWN,S])?1:0)-(FlxG.keys.anyPressed([UP,W])?1:0);
  for(pad in FlxG.gamepads.getActiveGamepads()) {
   var px=(pad.pressed.DPAD_RIGHT?1:0)-(pad.pressed.DPAD_LEFT?1:0);
   var py=(pad.pressed.DPAD_DOWN?1:0)-(pad.pressed.DPAD_UP?1:0);
   var ax=px!=0?px:pad.getXAxis(LEFT_ANALOG_STICK);
   var ay=py!=0?py:pad.getYAxis(LEFT_ANALOG_STICK);
   if(Math.abs(ax)>Math.abs(x))x=ax;
   if(Math.abs(ay)>Math.abs(y))y=ay;
  }
  var pointerNeutral=true;
  #if FLX_MOUSE
  pointerNeutral=!FlxG.mouse.pressed;
  #end
  #if FLX_TOUCH
  for(touch in FlxG.touches.list)if(touch.pressed)pointerNeutral=false;
  #end
  return state.step(x,y,FlxG.keys.anyPressed([ENTER,SPACE])||FlxG.gamepads.anyPressed(A),
   FlxG.keys.anyPressed([ESCAPE])||FlxG.gamepads.anyPressed(B),
   FlxG.keys.anyPressed([P])||FlxG.gamepads.anyPressed(START),pointerNeutral,elapsed);
 }
 #end
}
typedef DesktopFrame={dx:Int,dy:Int,accept:Bool,back:Bool,pause:Bool,neutral:Bool};
/** Pure edge/repeat state, independent of engine and physical devices. */
class DesktopInputState {
 var x=0;var y=0;var wait=0.0;
 var acceptHeld=false;var backHeld=false;var pauseHeld=false;
 public function new(){}
 public function step(rawX:Float,rawY:Float,accept:Bool,back:Bool,pause:Bool,pointerNeutral:Bool,elapsed:Float):DesktopFrame {
  var nx=rawX>0.5?1:rawX< -0.5?-1:0;
  var ny=rawY>0.5?1:rawY< -0.5?-1:0;
  var dx=0;var dy=0;
  if(nx!=x||ny!=y){dx=nx;dy=ny;wait=.35;}
  else if(nx!=0||ny!=0){wait-=Math.max(0,elapsed);if(wait<=0){dx=nx;dy=ny;wait=.12;}}
  x=nx;y=ny;
  var result:DesktopFrame={dx:dx,dy:dy,accept:accept&&!acceptHeld,back:back&&!backHeld,pause:pause&&!pauseHeld,
   neutral:nx==0&&ny==0&&!accept&&!back&&!pause&&pointerNeutral};
  acceptHeld=accept;backHeld=back;pauseHeld=pause;
  return result;
 }
}
#end
