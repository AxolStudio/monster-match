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
  // Native blit does not populate tile textData. Compare the actual rendered ink
  // against an independently rendered LEFT field translated by the expected offset.
  var reference=new PixelBitmapText(label.font);
  reference.autoSize=false;reference.fieldWidth=label.fieldWidth;
  reference.padding=label.padding;reference.alignment=FlxTextAlign.LEFT;
  reference.text=value;reference.checkPendingChanges(false);
  label.text=value;label.checkPendingChanges(false);
  check(FlxG.renderBlit,"alignment regression exercises native blit");
  var left=reference.pixels;var actual=label.pixels;
  check(left!=null&&actual!=null,"alignment has rendered pixel buffers for "+value);
  check(left.width==actual.width&&left.height==actual.height,"alignment canvases have equal bounds for "+value);
  var width=reference.getStringWidth(value);
  var shift=label.alignment==FlxTextAlign.CENTER
   ?Std.int((label.fieldWidth-width)/2)-label.padding
   :label.fieldWidth-width-2*label.padding;
  var leftCount=0;var actualCount=0;var leftMin=left.width;var leftMax=-1;var actualMin=actual.width;var actualMax=-1;
  var identical=true;
  for(y in 0...actual.height)for(x in 0...actual.width){
   var lp=left.getPixel32(x,y);var ap=actual.getPixel32(x,y);
   if((lp>>>24)!=0){leftCount++;if(x<leftMin)leftMin=x;if(x>leftMax)leftMax=x;}
   if((ap>>>24)!=0){actualCount++;if(x<actualMin)actualMin=x;if(x>actualMax)actualMax=x;}
   var sx=x-shift;var expected=sx>=0&&sx<left.width?left.getPixel32(sx,y):0;
   // Ignore RGB bits in transparent pixels; every visible pixel must match exactly.
   if((expected>>>24)==0){if((ap>>>24)!=0)identical=false;}
   else if(ap!=expected)identical=false;
  }
  check(leftCount>0&&actualCount==leftCount,"aligned glyph ink is present and not clipped for "+value);
  check(actualMin==leftMin+shift&&actualMax==leftMax+shift,
   "fixed-width "+Std.string(label.alignment)+" ink bounds translate by "+shift+" for "+value);
  check(identical,"fixed-width "+Std.string(label.alignment)+" matches every translated glyph pixel for "+value);
  reference.destroy();
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
