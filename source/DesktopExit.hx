#if desktop
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxBitmapFont;
/** Separate process-exit prompt. Existing pause Quit still returns to title. */
class DesktopExit extends FlxSubState {
 var focus=new DesktopFocus(2);
 var buttons:Array<ServiceButton>=[];
 var pending:Int=-1;
 public function new(){super(0xee140c1c);}
 override public function create():Void {
  super.create();
  var text=new PixelBitmapText(FlxBitmapFont.fromAngelCode("assets/images/simple_font.png","assets/images/simple_font.xml"));
  text.text="Exit game?";text.x=52;text.y=42;add(text);
  buttons=[new ServiceButton(18,68,58,"CANCEL",()->choose(0)),new ServiceButton(84,68,58,"EXIT",()->choose(1))];
  for(button in buttons)add(button);
  focus.paint(cast buttons);
 }
 function choose(index:Int):Void {if(focus.armed&&pending<0)pending=index;}
 override public function update(elapsed:Float):Void {
  super.update(elapsed);
  var frame=DesktopInput.sample(elapsed);
  if(pending>=0){if(frame.neutral){if(pending==1)Sys.exit(0);else close();}return;}
  var accept=focus.update(frame);focus.paint(cast buttons);
  if(focus.armed&&frame.back)choose(0);
  else if(accept)choose(focus.index);
 }
}
#end
