package com.axolstudio.monstermatch;

import java.util.HashMap;
import java.util.Map;

public final class AccountProgressTest {
    static final class Memory implements AccountProgress.Store {
        Map<String, Object> values = new HashMap<>();
        public Map<String, Object> load() { return new HashMap<>(values); }
        public void save(Map<String, Object> next) { values = new HashMap<>(next); }
    }
    static void check(boolean result, String message) { if (!result) throw new AssertionError(message); }
    public static void main(String[] args) {
        Memory disk = new Memory();
        disk.values.put("earned_victory", true);
        disk.values.put("pending_score", 123);
        disk.values.put("sent_A_victory", true);
        AccountProgress progress = new AccountProgress(disk);
        check(progress.hasUnassigned(), "Legacy events must remain available, unassigned");
        check(progress.pendingAwards("A").isEmpty() && progress.pendingScore("A") == -1, "No automatic legacy attribution to A");
        check(progress.pendingAwards("B").isEmpty() && progress.pendingScore("B") == -1, "No automatic legacy attribution to B");
        progress.award("A", "gardens"); progress.score("A", 500);
        check(progress.pendingAwards("B").isEmpty() && progress.pendingScore("B") == -1, "A's progress cannot leak to B");
        progress.ackAward("A", "gardens"); progress.ackScore("A", 500);
        progress.award("B", "spellshuffle"); progress.score("B", 42);
        check(progress.pendingAwards("A").isEmpty() && progress.pendingScore("A") == -1, "Acknowledgements remain scoped to A");
        progress = new AccountProgress(disk);
        check(progress.pendingScore("B") == 42 && progress.pendingAwards("B").contains("spellshuffle"), "Pending progress survives restart for its owner");
        check(progress.hasUnassigned(), "Signing in/restarting must not discard unassigned events");
        progress.claimUnassigned("B");
        check(!progress.hasUnassigned() && progress.pendingScore("B") == 123, "Explicit claim merges best score into selected owner");
        check(progress.pendingAwards("B").contains("victory") && !progress.pendingAwards("A").contains("victory"), "Claim is assigned only to selected player");
        progress = new AccountProgress(disk);
        check(!progress.hasUnassigned(), "Legacy records cannot be reimported after explicit claim");
        check(disk.values.containsKey("earned_victory"), "Legacy original data preserved");
        progress.award("", "drinkme"); progress.score("", 700);
        check(progress.pendingScore("A") == -1 && progress.pendingScore("B") == 123, "Anonymous play never attaches at sign-in");
        AccountSession session = new AccountSession();
        session.identify("A"); session.beginRun();
        int tokenA = session.token();
        session.suspend(); session.identify("B");
        check(!session.matches(tokenA, "A"), "Stale A completion rejected after switch");
        check(session.runOwner().equals("A"), "A's existing run stays A-owned while B is selected");
        session.beginRun(); check(session.runOwner().equals("B"), "New B run owns only new progress");
        session.suspend(); session.beginRun(); session.identify("A");
        check(session.runOwner().isEmpty(), "Anonymous run remains unassigned even after sign-in");
        int oldA = session.token(); session.suspend(); session.identify("A");
        check(!session.matches(oldA, "A"), "Same account reauthentication still invalidates old callbacks");
        check(!session.matches(session.token(), "B"), "Dispatch requires matching current identity");
        System.out.println("Account progress isolation tests passed");
    }
}
