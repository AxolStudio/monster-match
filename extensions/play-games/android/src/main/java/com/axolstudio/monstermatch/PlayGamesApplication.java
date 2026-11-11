package com.axolstudio.monstermatch;
import android.app.Application;
import android.util.Log;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.games.PlayGamesSdk;
/** SDK setup precedes Activity creation, as required by the documented v2 integration. */
public final class PlayGamesApplication extends Application {
 static boolean initialized;
 static String diagnostic = AuthDiagnostics.message(AuthDiagnostics.Stage.INIT, null);
 @Override public void onCreate() {
  super.onCreate();
  int id = getResources().getIdentifier("pgs_project_id", "string", getPackageName());
  if (id == 0 || !getString(id).trim().matches("[1-9][0-9]*")) {
   diagnostic = AuthDiagnostics.message(AuthDiagnostics.Stage.CONFIG, null);
   return;
  }
  int availability = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(this);
  if (availability != ConnectionResult.SUCCESS) {
   diagnostic = AuthDiagnostics.message(AuthDiagnostics.Stage.SERVICES, availability);
   return;
  }
  try {
   PlayGamesSdk.initialize(this);
   initialized = true;
   Log.i("MonsterPGS", "INIT ready");
  } catch (RuntimeException error) {
   diagnostic = AuthDiagnostics.message(AuthDiagnostics.Stage.INIT, null);
   Log.w("MonsterPGS", diagnostic);
  }
 }
}
