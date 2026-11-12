import DesktopInput.DesktopInputState;
class DesktopNavigationTest {
 static var checks=0;
 static function check(v:Bool,s:String){checks++;if(!v)throw s;}
 static function main(){
  var input=new DesktopInputState();
  var n=input.step(0,0,false,false,false,true,0);
  check(n.neutral,"idle neutral");
  var f=new DesktopFocus(4);
  check(!f.update(input.step(0,0,true,false,false,true,0)) && !f.armed,"held opening accept blocked");
  f.update(n);check(f.armed,"neutral arms focus");
  input.step(0,0,false,false,false,true,0);
  check(f.update(input.step(0,0,true,false,false,true,0)),"fresh accept works");
  check(!input.step(0,0,true,false,false,true,.1).accept,"held accept never repeats");
  input.step(0,0,false,false,false,true,0);
  var right=input.step(1,0,false,false,false,true,.01);check(right.dx==1&&!right.neutral,"direction immediate");
  f.update(right);check(f.index==1,"focus navigates");
  check(input.step(1,0,false,false,false,true,.1).dx==0,"repeat delay");
  check(input.step(1,0,false,false,false,true,.25).dx==1,"repeat begins");
  check(input.step(-1,0,false,false,false,true,0).dx == -1,"direction change immediate");
  var wrap=new DesktopFocus(4);wrap.update(n);wrap.update(input.step(0,-1,false,false,false,true,0));check(wrap.index==3,"negative wrap");
  check(input.step(.2,-.2,false,false,false,true,0).neutral,"analog deadzone");
  check(!input.step(0,0,false,false,false,false,0).neutral,"pointer hold is not neutral");
  f.reset();check(!f.armed&&!f.update(right),"reset blocks navigation until neutral");
  check(f.index==1,"blocked navigation preserves selection");
  input.step(0,0,false,false,false,true,0);
  check(input.step(0,0,false,true,false,true,0).back,"back press edge");
  check(!input.step(0,0,false,true,false,true,.2).back,"back does not repeat");
  input.step(0,0,false,false,false,true,0);
  check(input.step(0,0,false,false,true,true,0).pause,"pause press edge");
  check(!input.step(0,0,false,false,true,true,.2).pause,"pause does not repeat");
  var cancel=new DesktopFocus(2,1);cancel.update(n);check(cancel.index==1,"existing quit defaults Resume");
  check(!cancel.update({dx:0,dy:0,accept:true,back:true,pause:false,neutral:false}),"back beats simultaneous accept");
  input.step(0,0,false,false,false,true,0);
  input.step(1,0,false,false,false,true,0);
  check(input.step(1,0,false,false,false,true,10).dx==1,"long frame yields one repeat only");
  check(input.step(1,0,false,false,false,true,0).dx==0,"long frame has no burst backlog");
  trace(checks+" desktop navigation assertions passed");
 }
}
