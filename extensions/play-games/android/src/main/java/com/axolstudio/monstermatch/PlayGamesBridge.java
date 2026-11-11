package com.axolstudio.monstermatch;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.Toast;
import android.util.Log;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.games.FriendsResolutionRequiredException;
import com.google.android.gms.games.PlayGames;
import com.google.android.gms.games.leaderboard.LeaderboardVariant;
import java.util.HashSet;
import java.util.Set;
import java.util.Map;
import java.util.HashMap;
import org.haxe.extension.Extension;

/** Optional PGS v2 integration. Local gameplay never waits for any of these tasks. */
public final class PlayGamesBridge extends Extension {
    private static final int RC_GAMES_UI = 9130;
    private static final int RC_FRIENDS_CONSENT = 9131;
    private static boolean active, initialized, authenticated, connecting, sendingScore;
    private static String playerName = "";
    private static int authSequence;
    private static AccountSession session = new AccountSession();
    private static AccountProgress progress;
    private static Runnable afterScore;
    private static final Set<String> unlocking = new HashSet<>();
    private static final UiRequestGate uiGate = new UiRequestGate();
    private static int consentTicket;
    private static boolean resumeFriends;
    private static Runnable afterResume;
    private static AlertDialog claimDialog;
    private static String consentOwner = "";

    private static boolean valid(Activity a) {
        return active && a != null && a == mainActivity && !a.isFinishing() && !a.isDestroyed();
    }
    private static void ui(Runnable action) {
        final Activity a = mainActivity;
        if (valid(a)) a.runOnUiThread(() -> {
            if (!valid(a)) return;
            try { action.run(); }
            catch (RuntimeException error) { notice("Play Games isn't available right now. You can keep playing."); }
        });
    }
    private static SharedPreferences prefs() {
        return mainActivity.getSharedPreferences("monster_play_games", Activity.MODE_PRIVATE);
    }
    private static String resource(String name) {
        int id = mainActivity.getResources().getIdentifier(name, "string", mainActivity.getPackageName());
        return id == 0 ? "" : mainActivity.getString(id).trim();
    }
    private static void notice(String message) {
        if (valid(mainActivity) && uiGate.isForeground()) Toast.makeText(mainActivity, message, Toast.LENGTH_LONG).show();
    }
    @Override public void onCreate(Bundle state) {
        active = true;
        uiGate.reset();
        authenticated = connecting = sendingScore = false;
        authSequence++;
        session = new AccountSession();
        progress = new AccountProgress(new AccountProgress.Store() {
            public Map<String, Object> load() { return new HashMap<>(prefs().getAll()); }
            public void save(Map<String, Object> values) {
                SharedPreferences.Editor edit = prefs().edit();
                for (String key : prefs().getAll().keySet())
                    if (key.startsWith("v2.") && !values.containsKey(key)) edit.remove(key);
                for (Map.Entry<String, Object> entry : values.entrySet()) if (entry.getKey().startsWith("v2.")) {
                    Object value = entry.getValue();
                    if (value instanceof Boolean) edit.putBoolean(entry.getKey(), (Boolean) value);
                    else if (value instanceof Integer) edit.putInt(entry.getKey(), (Integer) value);
                }
                edit.apply();
            }
        });
        initialized = PlayGamesApplication.initialized;
        if (initialized) checkAuthentication();
    }
    @Override public void onResume() {
        uiGate.resume();
        uiGate.returnFromNativeUi();
        if (afterResume != null) {
            Runnable next = afterResume;
            afterResume = null;
            next.run();
            return;
        }
        if (resumeFriends) {
            resumeFriends = false;
            final int ticket = consentTicket;
            if (uiGate.canPresent(ticket)) connected(() -> {
                if (session.player().equals(consentOwner)) friendsConsent(ticket);
                else { uiGate.cancel(); notice("The Play Games profile changed. Open Friends again for the selected profile."); }
            });
            return;
        }
        if (initialized) checkAuthentication();
    }
    @Override public void onPause() {
        dismissClaim();
        boolean nativeUi = uiGate.ownsNativeUi();
        uiGate.pause();
        session.suspend();
        authenticated = false;
        sendingScore = false;
        unlocking.clear();
        afterScore = null;
        if (!nativeUi) { authSequence++; connecting = false; afterResume = null; }
    }
    @Override public void onDestroy() {
        dismissClaim();
        active = authenticated = initialized = connecting = sendingScore = false;
        authSequence++;
        session.suspend();
        afterScore = null;
        unlocking.clear();
        uiGate.reset();
        resumeFriends = false;
        afterResume = null;
    }
    private static void checkAuthentication() {
        if (!connecting) authenticate(null, false);
    }
    private static boolean authCurrent(Activity a, int request) { return valid(a) && authSequence == request; }
    private static void authenticate(Runnable next, boolean interactive) {
        final Activity a = mainActivity;
        if (!valid(a)) return;
        final int request = ++authSequence;
        final int uiTicket = uiGate.currentTicket();
        connecting = true;
        try {
        PlayGames.getGamesSignInClient(a).isAuthenticated()
            .addOnSuccessListener(result -> {
                if (!authCurrent(a, request)) return;
                if (result.isAuthenticated()) identify(a, request, next);
                else if (AuthDiagnostics.shouldSignIn(interactive, uiGate, uiTicket, authCurrent(a, request))) signIn(a, request, next);
                else authenticationFailed(a, request, next, AuthDiagnostics.Stage.CHECK, null);
            }).addOnFailureListener(error -> {
                if (!authCurrent(a, request)) return;
                recordFailure(AuthDiagnostics.Stage.CHECK, error);
                if (AuthDiagnostics.shouldSignIn(interactive, uiGate, uiTicket, authCurrent(a, request))) signIn(a, request, next);
                else authenticationFailed(a, request, next, AuthDiagnostics.Stage.CHECK, error);
            });
        } catch (RuntimeException error) {
            if (!authCurrent(a, request)) return;
            recordFailure(AuthDiagnostics.Stage.CHECK, error);
            if (AuthDiagnostics.shouldSignIn(interactive, uiGate, uiTicket, true)) signIn(a, request, next);
            else authenticationFailed(a, request, next, AuthDiagnostics.Stage.CHECK, error);
        }
    }
    private static String recordFailure(AuthDiagnostics.Stage stage, Exception error) {
        Integer status = error instanceof ApiException ? ((ApiException) error).getStatusCode() : null;
        String detail = AuthDiagnostics.message(stage, status);
        Log.w("MonsterPGS", detail);
        return detail;
    }
    private static void authenticationFailed(Activity a, int request, Runnable next, AuthDiagnostics.Stage stage, Exception error) {
        if (!authCurrent(a, request)) return;
        connecting = authenticated = false;
        session.suspend();
        String detail = recordFailure(stage, error);
        if (next != null) notice(detail);
    }
    private static void identify(Activity a, int request, Runnable next) {
        try {
        PlayGames.getPlayersClient(a).getCurrentPlayer().addOnSuccessListener(player -> {
            if (!authCurrent(a, request)) return;
            if (!uiGate.isForeground()) {
                connecting = false;
                afterResume = () -> authenticate(next, false);
                return;
            }
            String owner = player.getPlayerId();
            if (owner == null || owner.isEmpty()) { authenticationFailed(a, request, next, AuthDiagnostics.Stage.PLAYER, null); return; }
            if (!session.player().equals(owner)) { sendingScore = false; unlocking.clear(); afterScore = null; }
            session.identify(owner);
            playerName = player.getDisplayName();
            authenticated = true;
            connecting = false;
            retryOwnedProgress();
            if (next != null) next.run();
        }).addOnFailureListener(error -> authenticationFailed(a, request, next, AuthDiagnostics.Stage.PLAYER, error));
        } catch (RuntimeException error) {
            authenticationFailed(a, request, next, AuthDiagnostics.Stage.PLAYER, error);
        }
    }
    private static void connected(Runnable next) {
        if (!initialized) { notice(PlayGamesApplication.diagnostic); return; }
        if (connecting) { notice("Connecting to Play Games..."); return; }
        // Recheck the SDK identity for each explicit platform action.
        authenticate(next, true);
    }
    private static void signIn(Activity a, int request, Runnable next) {
        uiGate.leaveForNativeUi();
        try {
        PlayGames.getGamesSignInClient(a).signIn().addOnSuccessListener(result -> {
            if (!authCurrent(a, request)) return;
            finishSignInUi();
            if (result.isAuthenticated()) identify(a, request, next);
            else authenticationFailed(a, request, next, AuthDiagnostics.Stage.SIGN_IN, null);
        }).addOnFailureListener(error -> {
            if (authCurrent(a, request)) { finishSignInUi(); authenticationFailed(a, request, next, AuthDiagnostics.Stage.SIGN_IN, error); }
        });
        } catch (RuntimeException error) {
            finishSignInUi();
            authenticationFailed(a, request, next, AuthDiagnostics.Stage.SIGN_IN, error);
        }
    }
    private static void finishSignInUi() {
        if (uiGate.isForeground()) uiGate.returnFromNativeUi();
    }
    public static void award(String key) {
        if (key == null || !key.matches("[a-z_]+")) return;
        ui(() -> {
            String owner = session.runOwner();
            progress.award(owner, key);
            if (authenticated && owner.equals(session.player())) unlock(key);
        });
    }
    public static void beginRun() { ui(() -> session.beginRun()); }
    public static void trackEvent(String name, int amount) {
        if (!GameEventRules.accepts(name, amount)) return;
        ui(() -> {
            final String owner = session.runOwner();
            if (!authenticated || !GameEventRules.owned(owner, session.player())) return;
            final Activity a = mainActivity;
            final int token = session.token();
            verifyOwner(a, token, owner, () -> {
                // Increment calls are additive: do not implement blind application-level retries.
                String id = resource("event_" + name);
                if (!id.isEmpty()) {
                    try { PlayGames.getEventsClient(a).increment(id, amount); }
                    catch (RuntimeException ignored) { /* local play continues */ }
                }
                if (resource("game_stats_enabled").equals("true")) {
                    try {
                        com.google.android.gms.games.playergameevent.PlayerGameEvent event =
                            new com.google.android.gms.games.playergameevent.PlayerGameEvent.Builder(name)
                                .addProperty("amount", (long) amount).build();
                        PlayGames.getGameStatsClient(a).recordEvent(event);
                        PlayGames.getGameStatsClient(a).requestEventsUpload();
                    } catch (RuntimeException ignored) { /* local play continues */ }
                }
            }, () -> {});
        });
    }
    private static boolean same(Activity a, int token, String owner) {
        return valid(a) && authenticated && uiGate.isForeground() && session.matches(token, owner);
    }
    /** Check SDK account immediately before dispatch, not only cached sign-in state. */
    private static void verifyOwner(Activity a, int token, String owner, Runnable action, Runnable failure) {
        if (!same(a, token, owner)) return;
        PlayGames.getGamesSignInClient(a).isAuthenticated().addOnSuccessListener(result -> {
            if (!same(a, token, owner)) return;
            if (!result.isAuthenticated()) { loseIdentity(); return; }
            PlayGames.getPlayersClient(a).getCurrentPlayer().addOnSuccessListener(player -> {
                if (!same(a, token, owner)) return;
                if (!owner.equals(player.getPlayerId())) { loseIdentity(); return; }
                action.run();
            }).addOnFailureListener(error -> { if (same(a, token, owner)) failure.run(); });
        }).addOnFailureListener(error -> { if (same(a, token, owner)) failure.run(); });
    }
    private static void loseIdentity() {
        authenticated = connecting = sendingScore = false;
        authSequence++;
        session.suspend();
        unlocking.clear();
        afterScore = afterResume = null;
        uiGate.cancel();
        dismissClaim();
    }
    private static void retryOwnedProgress() {
        for (String key : progress.pendingAwards(session.player())) unlock(key);
        sendScore(null);
    }
    private static void unlock(String key) {
        String id = resource("achievement_" + key);
        final String owner = session.player();
        if (id.isEmpty() || !authenticated || owner.isEmpty() || !progress.pendingAwards(owner).contains(key)) return;
        final int token = session.token();
        final String sent = token + ":" + owner + ":" + key;
        if (!unlocking.add(sent)) return;
        final Activity a = mainActivity;
        verifyOwner(a, token, owner, () -> PlayGames.getAchievementsClient(a).unlockImmediate(id)
            .addOnSuccessListener(value -> {
                unlocking.remove(sent);
                if (same(a, token, owner)) progress.ackAward(owner, key);
            }).addOnFailureListener(error -> unlocking.remove(sent)), () -> unlocking.remove(sent));
    }
    public static void submitScore(int score) {
        if (score < 0) return;
        ui(() -> {
            String owner = session.runOwner();
            progress.score(owner, score);
            if (authenticated && owner.equals(session.player())) sendScore(null);
        });
    }
    private static void sendScore(Runnable next) {
        if (next != null) afterScore = next;
        if (sendingScore) return;
        String id = resource("leaderboard_high_scores");
        final String owner = session.player();
        final int score = progress.pendingScore(owner);
        if (score < 0 || id.isEmpty() || !authenticated || owner.isEmpty()) { finishScore(false); return; }
        final Activity a = mainActivity;
        final int token = session.token();
        sendingScore = true;
        verifyOwner(a, token, owner, () -> PlayGames.getLeaderboardsClient(a).submitScoreImmediate(id, score)
            .addOnSuccessListener(value -> {
                if (!same(a, token, owner)) return;
                progress.ackScore(owner, score);
                if (progress.pendingScore(owner) >= 0) { sendingScore = false; sendScore(null); }
                else finishScore(false);
            }).addOnFailureListener(error -> { if (same(a, token, owner)) finishScore(true); }), () -> finishScore(true));
    }
    private static void dismissClaim() {
        if (claimDialog != null) { claimDialog.setOnCancelListener(null); claimDialog.dismiss(); claimDialog = null; }
    }
    /** Anonymous progress is never silently adopted by the next account to sign in. */
    private static void offerUnassigned(int ticket, Runnable next) {
        final Activity a = mainActivity;
        final String owner = session.player();
        final int token = session.token();
        if (!present(a, ticket) || !same(a, token, owner)) return;
        if (!progress.hasUnassigned()) { next.run(); return; }
        String name = playerName == null || playerName.isEmpty() ? "this player" : playerName;
        int best = progress.unassignedBest();
        String details = progress.pendingAwards("").size() + " offline achievement(s)" + (best >= 0 ? " and a best score of " + best : "");
        dismissClaim();
        claimDialog = new AlertDialog.Builder(a).setTitle("Unassigned offline progress")
            .setMessage("Play Games profile: " + name + "\n\nThis device has " + details + ". Add all of this progress to this profile only if it is yours. Otherwise it stays unassigned on this device.")
            .setNegativeButton("Keep on device", (dialog, which) -> { claimDialog = null; if (present(a, ticket) && same(a, token, owner)) next.run(); })
            .setPositiveButton("Add to this profile", (dialog, which) -> {
                claimDialog = null;
                if (!present(a, ticket)) return;
                verifyOwner(a, token, owner, () -> {
                    if (!present(a, ticket)) return;
                    progress.claimUnassigned(owner);
                    retryOwnedProgress();
                    next.run();
                }, () -> notice("Progress stays on this device. Play Games couldn't be checked."));
            }).create();
        claimDialog.show();
    }
    private static void finishScore(boolean failed) {
        sendingScore = false;
        Runnable next = afterScore;
        afterScore = null;
        if (failed && next != null) notice("Your score is saved locally; the online score couldn't be sent.");
        if (next != null && valid(mainActivity)) next.run();
    }
    public static void showAchievements() {
        ui(() -> {
            if (!uiGate.isForeground()) return;
            if (connecting) { notice("Connecting to Play Games..."); return; }
            final int ticket = uiGate.begin();
            connected(() -> {
            offerUnassigned(ticket, () -> {
            final Activity a = mainActivity;
            final String owner = session.player();
            final int token = session.token();
            if (!present(a, ticket)) return;
            PlayGames.getAchievementsClient(a).getAchievementsIntent()
                .addOnSuccessListener(intent -> { if (same(a, token, owner)) launch(a, intent, ticket); })
                .addOnFailureListener(error -> { if (valid(a)) notice("Achievements couldn't be opened. You can keep playing."); });
            });
            });
        });
    }
    public static void showLeaderboard() { showScores(false); }
    public static void showFriends() { showScores(true); }
    private static void showScores(boolean friends) {
        ui(() -> {
            if (!uiGate.isForeground()) return;
            if (connecting) { notice("Connecting to Play Games..."); return; }
            if (resource("leaderboard_high_scores").isEmpty()) {
                notice("Online scores aren't available in this test build yet.");
                return;
            }
            final int ticket = uiGate.begin();
            connected(() -> {
                if (!present(mainActivity, ticket)) return;
                offerUnassigned(ticket, () -> {
                sendScore(() -> {
                    if (!present(mainActivity, ticket)) return;
                    if (friends) friendsConsent(ticket); else board(false, ticket);
                });
                });
            });
        });
    }
    public static void cancelUi() { ui(() -> { uiGate.cancel(); dismissClaim(); afterScore = afterResume = null; resumeFriends = false; }); }
    private static boolean present(Activity a, int ticket) { return valid(a) && uiGate.canPresent(ticket); }
    private static void friendsConsent(int ticket) {
        final Activity a = mainActivity;
        final String owner = session.player();
        final int token = session.token();
        if (!present(a, ticket)) return;
        PlayGames.getPlayersClient(a).loadFriends(1, false).addOnSuccessListener(data -> {
            if (data.get() != null) data.get().release();
            if (present(a, ticket) && same(a, token, owner)) board(true, ticket);
        }).addOnFailureListener(error -> {
            if (!present(a, ticket) || !same(a, token, owner)) return;
            if (error instanceof FriendsResolutionRequiredException) {
                try {
                    consentTicket = ticket;
                    consentOwner = owner;
                    uiGate.leaveForNativeUi();
                    ((FriendsResolutionRequiredException) error).startResolutionForResult(a, RC_FRIENDS_CONSENT);
                }
                catch (Exception failure) {
                    uiGate.returnFromNativeUi();
                    notice("Friends scores couldn't be opened. Local scores still work.");
                }
            } else notice("Friends scores couldn't be loaded. Local scores still work.");
        });
    }
    @Override public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == RC_GAMES_UI || requestCode == RC_FRIENDS_CONSENT) uiGate.returnFromNativeUi();
        if (requestCode == RC_FRIENDS_CONSENT) {
            if (resultCode == Activity.RESULT_OK) resumeFriends = true;
            else notice("Friends access wasn't shared. You can keep playing.");
            return false;
        }
        return true;
    }
    private static void board(boolean friends, int ticket) {
        String id = resource("leaderboard_high_scores");
        if (id.isEmpty()) { notice("Online scores aren't available in this test build yet."); return; }
        final Activity a = mainActivity;
        final String owner = session.player();
        final int token = session.token();
        if (!present(a, ticket)) return;
        PlayGames.getLeaderboardsClient(a).getLeaderboardIntent(id, LeaderboardVariant.TIME_SPAN_ALL_TIME,
            friends ? LeaderboardVariant.COLLECTION_FRIENDS : LeaderboardVariant.COLLECTION_PUBLIC)
            .addOnSuccessListener(intent -> { if (same(a, token, owner)) launch(a, intent, ticket); })
            .addOnFailureListener(error -> { if (valid(a)) notice("Online scores couldn't be opened. Local scores still work."); });
    }
    private static void launch(Activity a, Intent intent, int ticket) {
        if (present(a, ticket)) {
            uiGate.leaveForNativeUi();
            try { a.startActivityForResult(intent, RC_GAMES_UI); }
            catch (RuntimeException error) {
                uiGate.returnFromNativeUi();
                notice("Play Games couldn't be opened. You can keep playing.");
            }
        }
    }
}
