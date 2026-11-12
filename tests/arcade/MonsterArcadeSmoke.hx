import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import openfl.events.KeyboardEvent;
/** Normal desktop boot/state loop; only spell/gameover entry is explicitly fixture-seeded. */
class MonsterArcadeSmoke extends DesktopBoot {
 override public function create():Void {
  var driver=new MonsterSmokeDriver();FlxG.plugins.addPlugin(driver);
  try {driver.prepare();super.create();FlxG.autoPause=false;}catch(e:Dynamic)driver.fail(Std.string(e));
 }
}
@:access(TitleState)
@:access(HelpState)
@:access(CreditsState)
@:access(PlayState)
@:access(PauseScreen)
@:access(ConfirmQuit)
@:access(SpellChoice)
@:access(GameOver)
@:access(HiScoreState)
@:access(DesktopExit)
@:access(flixel.input.gamepad.FlxGamepadManager)
@:access(flixel.input.gamepad.FlxGamepad)
private class MonsterSmokeDriver extends FlxBasic {
 var device:String;var output:String;var pad:FlxGamepad;
 var phase=0;var marked=-1;var started:Float;var phaseStarted:Float;var heartbeat=0.0;
 var held=false;var key:FlxKey;var button:FlxGamepadInputID;var done=false;
 var checks:Array<String>=[];
 var helpY:Float;var selected:Block;var selectedX:Float;var initialValues:Array<Int>;
 var oldPlay:PlayState;var spells:Float;
 public function new(){super();visible=false;device=Sys.getEnv("MONSTER_TEST_DEVICE");output=Sys.getEnv("MONSTER_TEST_RESULT");started=phaseStarted=haxe.Timer.stamp();}
 function require(ok:Bool,label:String):Void {if(!ok)throw label;}
 function pass(label:String):Void {checks.push(label);}
 public function prepare():Void {
  require(device=="keyboard"||device=="gamepad","unknown device");
  require(FlxG.fullscreen,"fullscreen startup");
  FlxG.random.initialSeed=271828;FlxG.keys.reset();pad=FlxG.gamepads.createByID(0,XINPUT);pad.reset();
  FlxG.signals.postUpdate.add(step);pass("fullscreen, deterministic random seed, synthetic hardware only");
 }
 function charCode(k:FlxKey):Int {var c:Int=cast k;return c>=65&&c<=90?c+32:0;}
 function pulse(k:FlxKey,b:FlxGamepadInputID):Void {
  require(!held,"overlapping pulse");key=k;button=b;
  if(device=="keyboard"){
   require(!FlxG.gamepads.anyButton(),"keyboard path used pad");
   FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,false,charCode(k),k));
   require(FlxG.keys.checkStatus(k,PRESSED)||FlxG.keys.checkStatus(k,JUST_PRESSED),"key-down delivery "+Std.string(k));
  }else{
   require(FlxG.keys.firstPressed()==-1,"pad path used keyboard");pad.getButton(pad.mapping.getRawID(b)).press();
  }
  held=true;
 }
 function release():Void {
  if(device=="keyboard"){
   var before=FlxG.keys.checkStatus(key,PRESSED)||FlxG.keys.checkStatus(key,JUST_PRESSED);
   FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP,true,false,charCode(key),key));
   if(before)require(FlxG.keys.checkStatus(key,JUST_RELEASED),"key-up delivery "+Std.string(key));
  }else pad.getButton(pad.mapping.getRawID(button)).release();
  held=false;
 }
 function title():TitleState return Std.isOfType(FlxG.state,TitleState)?cast FlxG.state:null;
 function play():PlayState return Std.isOfType(FlxG.state,PlayState)?cast FlxG.state:null;
 function pause():PauseScreen {var p=play();return p!=null&&Std.isOfType(p.subState,PauseScreen)?cast p.subState:null;}
 function idle():Bool {var p=play();return p!=null&&p.ready&&p.subState==null&&!p.swapping&&!p.castingSpell&&!p.changingEnv&&p.desktopCursor.armed;}
 function chooseTitle(index:Int,next:Int):Void {
  var t=title();if(t==null||!t.ready||!t.desktopFocus.armed||t.subState!=null)return;
  if(t.desktopFocus.index!=index)pulse(RIGHT,DPAD_RIGHT);else{pulse(ENTER,A);phase=next;}
 }
 function step():Void {
  if(done)return;
  try {
   if(marked!=phase){marked=phase;phaseStarted=haxe.Timer.stamp();sys.io.File.saveContent(output+".progress","phase "+phase);}
   if(haxe.Timer.stamp()-heartbeat>1){
    heartbeat=haxe.Timer.stamp();var p=play();
    sys.io.File.saveContent(output+".heartbeat",haxe.Json.stringify({phase:phase,state:Type.getClassName(Type.getClass(FlxG.state)),elapsed:heartbeat-started,
     ready:p==null?false:p.ready,swapping:p==null?false:p.swapping,casting:p==null?false:p.castingSpell,changing:p==null?false:p.changingEnv,
     substate:FlxG.state.subState==null?"none":Type.getClassName(Type.getClass(FlxG.state.subState))}));
   }
   if(haxe.Timer.stamp()-started>225||haxe.Timer.stamp()-phaseStarted>45)throw "smoke timeout phase "+phase;
   if(held){release();return;}
   switch(phase){
    case 0: chooseTitle(1,1);
    case 1:
     if(Std.isOfType(FlxG.state,HelpState)){var h:HelpState=cast FlxG.state;if(h.ready&&h.desktopFocus.armed){helpY=h.story.y;pulse(DOWN,DPAD_DOWN);phase=2;}}
    case 2:
     var h:HelpState=cast FlxG.state;if(h.story.y<helpY){pass("Help opens and scrolls with device");pulse(ESCAPE,B);phase=3;}
    case 3: chooseTitle(2,4);
    case 4:
     if(Std.isOfType(FlxG.state,CreditsState)){var c:CreditsState=cast FlxG.state;if(c.ready&&c.desktopFocus.armed){pass("Credits opens after Help back");pulse(ESCAPE,B);phase=5;}}
    case 5: chooseTitle(0,6);
    case 6:
     if(Std.isOfType(FlxG.state,HelpState)){var h:HelpState=cast FlxG.state;if(h.ready&&h.desktopFocus.armed){pass("first-run tutorial reached by Play");pulse(ESCAPE,B);}}
     else if(idle()){
      var p=play();require(p.desktopCursor.column==0&&p.desktopCursor.row==0,"board starts at bottom left");
      require(p.heroCounter.y+p.heroCounter.height+p.heroCounter.borderSize<p.envTitle.y,"actual gameplay counter layout");
      pass("Play enters actual initialized board");pulse(ENTER,A);phase=7;
     }
    case 7:
     var p=play();if(p.selectedBlock!=-1){
      selected=p.desktopLiveBlock(p.selectedBlock);require(selected!=null,"selected live board object");
      require(selected.x==PlayState.SPAWNX&&selected.y==PlayState.SPAWNY,"selection follows spatial cell");
      selectedX=selected.x;pass("accept selects spatial board cell");pulse(RIGHT,DPAD_RIGHT);phase=8;
     }
    case 8:
     var p=play();if(p.desktopCursor.column==1){require(p.selectedBlock==selected.ID,"navigation keeps selected origin");pulse(ENTER,A);phase=9;}
    case 9:
     var p=play();if(p.swapping&&p.selectedBlock==-1){require(selected.x!=selectedX,"real swap tween moved selected block");pass("adjacent board accept enters real swap and moves object");phase=10;}
    case 10: if(idle()){pulse(ESCAPE,START);phase=11;}
    case 11:
     var p=pause();if(p!=null&&p.ready&&p.desktopFocus.armed){pass("pause opens by device");pulse(ESCAPE,B);phase=12;}
    case 12:
     if(idle()){
      pass("pause cancel resumes gameplay");var p=play();spells=Counts.counts.get("spells_cast");
      p.castingSpell=true;p.openSubState(new SpellChoice(p.returnFromSpellChoice));pass("fixture-seeded spell availability, not earned progression");phase=13;
     }
    case 13:
     var p=play();if(Std.isOfType(p.subState,SpellChoice)){var s:SpellChoice=cast p.subState;if(s.ready&&s.desktopFocus.armed){require(s.desktopFocus.index==0,"spell default focus");pulse(RIGHT,DPAD_RIGHT);phase=14;}}
    case 14:
     var s:SpellChoice=cast play().subState;if(s.desktopFocus.index==1){require(s.currentHover==1,"visible spell focus follows device");pulse(ENTER,A);phase=15;}
    case 15:
     if(idle()){
      require(Counts.counts.get("spells_cast")==spells+1,"real spell callback increments count once");pass("spell device selection executes production callback");
      var p=play();oldPlay=p;p.ready=false;p.openSubState(new GameOver(false,1234,false));
      pass("fixture-seeded defeat score 1234, not full gameplay playthrough");phase=16;
     }
    case 16:
     if(Std.isOfType(play().subState,GameOver)){
      var g:GameOver=cast play().subState;
      if(g.ready&&g.cursor!=null&&g.desktopInitials!=null){initialValues=g.initVals.copy();pulse(DOWN,DPAD_DOWN);phase=17;}
     }
    case 17:
     var g:GameOver=cast play().subState;if(g.initVals[0]!=initialValues[0]){pulse(RIGHT,DPAD_RIGHT);phase=18;}
    case 18:
     var g:GameOver=cast play().subState;if(g.sel==1){pulse(DOWN,DPAD_DOWN);phase=19;}
    case 19:
     var g:GameOver=cast play().subState;if(g.initVals[1]!=initialValues[1]){pulse(RIGHT,DPAD_RIGHT);phase=20;}
    case 20:
     var g:GameOver=cast play().subState;if(g.sel==2){pulse(DOWN,DPAD_DOWN);phase=21;}
    case 21:
     var g:GameOver=cast play().subState;if(g.initVals[2]!=initialValues[2]){pass("all three initials edited by device");pulse(ENTER,A);phase=22;}
    case 22:
     if(Std.isOfType(FlxG.state,HiScoreState)){
      var s:HiScoreState=cast FlxG.state;if(s.ready&&s.desktopFocus.armed){
       var rows:Array<Dynamic>=Globals.Save.data.localScores;
       require(rows!=null&&rows.filter(r->r.amount==1234).length==1,"score recorded once locally");
       require(Globals.Save.data.init=="AAA","edited initials persisted");pass("offline score flow reaches local scores without network");
       require(s.desktopFocus.index==0,"retry default");pulse(ENTER,A);phase=23;
      }
     }
    case 23: if(idle()){require(play()!=oldPlay,"retry creates fresh PlayState");pass("retry creates and initializes real new game");pulse(ESCAPE,START);phase=24;}
    case 24:
     var p=pause();if(p!=null&&p.ready&&p.desktopFocus.armed){pulse(RIGHT,DPAD_RIGHT);phase=25;}
    case 25:
     var p=pause();if(p.desktopFocus.index==1){pulse(ENTER,A);phase=26;}
    case 26:
     var p=pause();if(Std.isOfType(p.subState,ConfirmQuit)){var c:ConfirmQuit=cast p.subState;if(c.ready&&c.desktopFocus.armed){require(c.desktopFocus.index==1,"return-title confirmation defaults Resume");pulse(ESCAPE,B);phase=27;}}
    case 27:
     var p=pause();if(p.subState==null&&p.desktopFocus.armed){pass("return-title cancel preserves pause");pulse(ENTER,A);phase=28;}
    case 28:
     var p=pause();if(Std.isOfType(p.subState,ConfirmQuit)){var c:ConfirmQuit=cast p.subState;if(c.ready&&c.desktopFocus.armed){pulse(LEFT,DPAD_LEFT);phase=29;}}
    case 29:
     var c:ConfirmQuit=cast pause().subState;if(c.desktopFocus.index==0){pulse(ENTER,A);phase=30;}
    case 30: chooseTitle(3,31);
    case 31:
     var t=title();if(t!=null&&Std.isOfType(t.subState,DesktopExit)){var e:DesktopExit=cast t.subState;if(e.focus.armed){require(e.focus.index==0,"OS Exit defaults Cancel");pulse(ESCAPE,B);phase=32;}}
    case 32:
     var t=title();if(t!=null&&t.subState==null&&t.desktopFocus.armed){pass("OS Exit cancel retains title");pulse(ENTER,A);phase=33;}
    case 33:
     var t=title();if(t!=null&&Std.isOfType(t.subState,DesktopExit)){var e:DesktopExit=cast t.subState;if(e.focus.armed){pulse(RIGHT,DPAD_RIGHT);phase=34;}}
    case 34:
     var e:DesktopExit=cast title().subState;if(e.focus.index==1){pass("device selected actual OS Exit");write(true,true,null);pulse(ENTER,A);phase=35;}
    case 35: // Only production DesktopExit may terminate successfully; timeout fails otherwise.
    default:throw "unknown phase "+phase;
   }
  }catch(e:Dynamic)fail(Std.string(e)+"\n"+haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
 }
 function write(passed:Bool,exitRequested:Bool,error:Null<String>):Void {
  sys.io.File.saveContent(output,haxe.Json.stringify({schema:1,mode:"real-loop-smoke",device:device,passed:passed,exitRequested:exitRequested,error:error,checks:checks,
   notVerified:["physical controller and hotplug","cabinet focus","live online services","full gameplay playthrough; spell and defeat entry fixture-seeded"]},null,"  "));
 }
 public function fail(error:String):Void {done=true;write(false,false,error);Sys.exit(1);}
}
