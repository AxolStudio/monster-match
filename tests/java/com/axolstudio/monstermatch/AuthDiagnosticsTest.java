package com.axolstudio.monstermatch;
public final class AuthDiagnosticsTest {
 public static void main(String[] args) {
  require(AuthDiagnostics.shouldSignIn(true,true,true), "explicit foreground retry blocked");
  require(!AuthDiagnostics.shouldSignIn(false,true,true), "automatic request prompted");
  require(!AuthDiagnostics.shouldSignIn(true,false,true), "background request prompted");
  require(!AuthDiagnostics.shouldSignIn(true,true,false), "stale request prompted");
  require(AuthDiagnostics.message(AuthDiagnostics.Stage.CHECK,10).equals("Play Games: CHECK / 10. Local play still works."),"numeric status lost");
  require(AuthDiagnostics.message(AuthDiagnostics.Stage.SIGN_IN,null).equals("Play Games: SIGN_IN / UNKNOWN. Local play still works."),"missing status misreported");
  require(AuthDiagnostics.message(AuthDiagnostics.Stage.PLAYER,-1).contains("PLAYER / -1"),"stage lost");
  UiRequestGate gate = new UiRequestGate();
  gate.resume();
  int ticket = gate.begin();
  require(AuthDiagnostics.shouldSignIn(true,gate,ticket,true),"valid explicit request blocked");
  gate.cancel();
  require(!AuthDiagnostics.shouldSignIn(true,gate,ticket,true),"canceled delayed check opened sign-in");
  ticket = gate.begin(); gate.pause();
  require(!AuthDiagnostics.shouldSignIn(true,gate,ticket,true),"background delayed check opened sign-in");
  gate.resume(); ticket = gate.begin(); gate.begin();
  require(!AuthDiagnostics.shouldSignIn(true,gate,ticket,true),"replaced request opened sign-in");
  ticket = gate.currentTicket();
  require(!AuthDiagnostics.shouldSignIn(true,gate,ticket,false),"destroyed activity request opened sign-in");
  require(!AuthDiagnostics.shouldSignIn(false,gate,ticket,true),"startup prompted manually");
  System.out.println("AuthDiagnosticsTest PASS");
 }
 private static void require(boolean condition,String text){if(!condition)throw new AssertionError(text);}
}
