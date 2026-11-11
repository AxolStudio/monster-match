package com.axolstudio.monstermatch;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/** Durable progress partitioned by originating player; empty owner means unassigned. */
final class AccountProgress {
    interface Store { Map<String, Object> load(); void save(Map<String, Object> values); }
    private final Store store;
    private final Map<String, Object> data;
    AccountProgress(Store store) {
        this.store = store;
        data = new HashMap<>(store.load());
        if (!flag("v2.migrated")) {
            for (String key : new HashSet<>(data.keySet()))
                if (key.startsWith("earned_") && flag(key)) data.put(prefix("") + "earned." + key.substring(7), true);
            int legacyScore = number("pending_score");
            if (legacyScore >= 0) data.put(prefix("") + "best", legacyScore);
            // Preserve legacy keys verbatim, but never use them for automatic account attribution.
            data.put("v2.migrated", true);
            save();
        }
    }
    private static String prefix(String owner) {
        if (owner.isEmpty()) return "v2.unassigned.";
        StringBuilder encoded = new StringBuilder();
        for (int i = 0; i < owner.length(); i++) encoded.append(Integer.toHexString(owner.charAt(i))).append('_');
        return "v2.player." + encoded + ".";
    }
    private boolean flag(String key) { return Boolean.TRUE.equals(data.get(key)); }
    private int number(String key) { Object value = data.get(key); return value instanceof Integer ? (Integer) value : -1; }
    private void save() { store.save(new HashMap<>(data)); }
    void award(String owner, String key) { data.put(prefix(owner) + "earned." + key, true); save(); }
    void score(String owner, int value) {
        if (value < 0) return;
        String key = prefix(owner) + "best";
        data.put(key, Math.max(value, number(key))); save();
    }
    Set<String> pendingAwards(String owner) {
        Set<String> pending = new HashSet<>();
        String start = prefix(owner) + "earned.";
        for (String key : data.keySet()) if (key.startsWith(start) && flag(key)) {
            String award = key.substring(start.length());
            if (!flag(prefix(owner) + "ack.award." + award)) pending.add(award);
        }
        return pending;
    }
    int pendingScore(String owner) {
        int best = number(prefix(owner) + "best");
        return best > number(prefix(owner) + "ack.score") ? best : -1;
    }
    void ackAward(String owner, String key) { data.put(prefix(owner) + "ack.award." + key, true); save(); }
    void ackScore(String owner, int value) {
        String key = prefix(owner) + "ack.score";
        data.put(key, Math.max(value, number(key))); save();
    }
    boolean hasUnassigned() { return !pendingAwards("").isEmpty() || pendingScore("") >= 0; }
    int unassignedBest() { return pendingScore(""); }
    void claimUnassigned(String owner) {
        if (owner.isEmpty()) throw new IllegalArgumentException("A confirmed player is required");
        for (String key : pendingAwards("")) data.put(prefix(owner) + "earned." + key, true);
        int best = pendingScore("");
        if (best >= 0) data.put(prefix(owner) + "best", Math.max(best, number(prefix(owner) + "best")));
        for (String key : new HashSet<>(data.keySet())) if (key.startsWith(prefix(""))) data.remove(key);
        save();
    }
}
