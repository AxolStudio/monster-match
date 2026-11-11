package com.axolstudio.monstermatch;

final class GameEventRules {
    static boolean accepts(String name, int amount) {
        if (amount <= 0 || name == null) return false;
        switch (name) {
            case "game_started": case "monster_summoned": case "hero_defeated":
            case "spell_cast": case "game_completed": case "victory": return true;
            default: return false;
        }
    }
    static boolean owned(String origin, String current) {
        return origin != null && !origin.isEmpty() && origin.equals(current);
    }
}
