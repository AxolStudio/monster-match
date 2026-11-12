import flixel.FlxG;
import flixel.util.FlxSave;
class DesktopOnlineRegressionTest {
 static function main(){
  FlxG.game={};var save=new FlxSave();
  if(DesktopOnlineConfig.gameKey()!="")throw "Regression embeds active identifier";
  if(DesktopOnline.start(save)||DesktopOnline.ready||FlxSave.log.length!=0)throw "Regression starts online storage";
  DesktopOnline.sendEvent("test");
  var token=DesktopOnline.submitScore(1,"ABC");
  if(DesktopOnline.takeResult(token).status!="unavailable")throw "Regression queues network score";
  trace("3 regression offline guards passed");
 }
}
