import openfl.display.Sprite;
import flixel.FlxGame;
class MonsterArcadeTestMain extends Sprite {
 public function new(){
  super();
  try {
  if(Sys.getEnv("MONSTER_TEST_DEVICE")!=null)
   addChild(new MonsterGuardedGame(160,120,MonsterArcadeSmoke,120,60,true,true));
  else addChild(new MonsterGuardedGame(160,120,MonsterArcadeRegression,120,60,true,true));
  flixel.FlxG.autoPause=false;
  } catch(e:Dynamic) {
   sys.io.File.saveContent(Sys.getEnv("MONSTER_TEST_RESULT"),haxe.Json.stringify({passed:false,failures:1,error:Std.string(e)+"\n"+haxe.CallStack.toString(haxe.CallStack.exceptionStack())}));
   Sys.exit(1);
  }
 }
}
/** Never leave an invisible native error dialog waiting until the runner timeout. */
private class MonsterGuardedGame extends FlxGame {
 override function onEnterFrame(event:openfl.events.Event):Void {
  try super.onEnterFrame(event) catch(e:Dynamic){
   sys.io.File.saveContent(Sys.getEnv("MONSTER_TEST_RESULT"),haxe.Json.stringify({passed:false,failures:1,error:Std.string(e)+"\n"+haxe.CallStack.toString(haxe.CallStack.exceptionStack())}));
   Sys.exit(1);
  }
 }
}
