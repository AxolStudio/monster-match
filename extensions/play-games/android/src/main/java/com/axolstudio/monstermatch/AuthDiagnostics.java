package com.axolstudio.monstermatch;
/** Diagnostics are fixed stages and numeric codes only: never account or exception text. */
final class AuthDiagnostics {
 enum Stage { CONFIG, SERVICES, INIT, CHECK, SIGN_IN, PLAYER }
 static boolean shouldSignIn(boolean interactive, boolean foreground, boolean current) {
  return interactive && foreground && current;
 }
 static boolean shouldSignIn(boolean interactive, UiRequestGate gate, int ticket, boolean current) {
  return shouldSignIn(interactive, gate.canPresent(ticket), current);
 }
 static String message(Stage stage, Integer status) {
  return "Play Games: " + stage.name() + " / " + (status == null ? "UNKNOWN" : status.toString()) + ". Local play still works.";
 }
}
