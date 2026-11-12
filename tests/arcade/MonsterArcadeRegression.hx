import flixel.FlxG;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxText.FlxTextAlign;
import openfl.display.BitmapData;
@:access(flixel.text.FlxBitmapText)
@:access(flixel.system.debug.log.BitmapLog)
class MonsterArcadeRegression extends PlayState {
 var ran=false;
 var checks:Array<String>=[];
 function check(ok:Bool,name:String):Void {if(!ok)throw name;checks.push(name);}
 override public function create():Void {
  Globals.initGame();FlxG.autoPause=false;FlxG.random.initialSeed=314159;
  super.create();
 }
 function layout(label:PixelBitmapText,value:String):Void {
  label.text=value;label.checkPendingChanges(true);
  var data:Array<Float>=cast label.textData;
  var expected=label.font.minOffsetX+(label.alignment==FlxTextAlign.CENTER
   ?Std.int((label.fieldWidth-label.getStringWidth(value))/2)
   :label.fieldWidth-label.getStringWidth(value)-label.padding);
  check(data.length>1&&data[1]==expected,"fixed-width "+Std.string(label.alignment)+" aligns "+value);
 }
 override public function update(elapsed:Float):Void {
  super.update(elapsed);if(ran)return;ran=true;
  try {
   check(FlxG.fullscreen,"native fullscreen");
   var font=FlxBitmapFont.fromAngelCode("assets/images/fancy_font.png","assets/images/fancy_font.xml");
   var label=new PixelBitmapText(font);label.autoSize=false;label.fieldWidth=60;label.alignment=FlxTextAlign.CENTER;
   layout(label,"Garden");label.alignment=FlxTextAlign.RIGHT;layout(label,"1");layout(label,"123");
   label.text="Save and quit?";label.draw();check(label.textWidth>0&&label.textHeight>0,"native bitmap first layout");
   label.text="Two\nlines";label.draw();check(label.textHeight>7,"native bitmap multiline resize");label.destroy();
   check(heroCounter.y+heroCounter.height+heroCounter.borderSize<envTitle.y,"actual counter outline does not overlap zone title");
   var bitmap=new BitmapData(1,1,true,0xffffffff);FlxG.bitmapLog.add(bitmap);FlxG.bitmapLog.clear();
   #if FLX_DEBUG
   check(FlxG.bitmapLog.window.index<0,"cleared bitmap log has no retained index");
   #else
   throw "Regression executable must include FLX_DEBUG for bitmap-log assertion";
   #end
   sys.io.File.saveContent(Sys.getEnv("MONSTER_TEST_RESULT"),haxe.Json.stringify({passed:true,failures:0,checks:checks}));Sys.exit(0);
  }catch(e:Dynamic){
   sys.io.File.saveContent(Sys.getEnv("MONSTER_TEST_RESULT"),haxe.Json.stringify({passed:false,failures:1,checks:checks,error:Std.string(e)+"\n"+haxe.CallStack.toString(haxe.CallStack.exceptionStack())}));Sys.exit(1);
  }
 }
}
