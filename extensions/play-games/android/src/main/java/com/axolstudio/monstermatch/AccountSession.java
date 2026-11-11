package com.axolstudio.monstermatch;

/** Main-thread identity epoch. A run's origin never follows a later account switch. */
final class AccountSession {
    private String player = "", run = "";
    private int epoch;
    void suspend() { player = ""; epoch++; }
    void identify(String id) { if (!player.equals(id)) { player = id; epoch++; } }
    String player() { return player; }
    int token() { return epoch; }
    boolean matches(int token, String owner) { return epoch == token && !owner.isEmpty() && player.equals(owner); }
    void beginRun() { run = player; }
    String runOwner() { return run; }
}
