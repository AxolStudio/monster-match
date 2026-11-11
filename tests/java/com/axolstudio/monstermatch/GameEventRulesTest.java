package com.axolstudio.monstermatch;
public class GameEventRulesTest {
    public static void main(String[] args) {
        if (!GameEventRules.accepts("monster_summoned", 1)) throw new AssertionError("Valid event");
        if (GameEventRules.accepts("bad", 1) || GameEventRules.accepts("victory", -1) || GameEventRules.accepts(null, 1)) throw new AssertionError("Invalid event");
        if (GameEventRules.owned("", "B") || GameEventRules.owned("A", "B") || GameEventRules.owned(null, "B")) throw new AssertionError("Cross-account event");
        if (!GameEventRules.owned("A", "A")) throw new AssertionError("Owner event");
        System.out.println("Game event ownership tests passed");
    }
}
