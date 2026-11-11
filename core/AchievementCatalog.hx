/** Stable game events shared with the original Newgrounds medals. */
class AchievementCatalog {
    private static final keys = ["gardens", "dungeons", "catacomb", "viaduct", "ruins", "ramparts", "sanctum", "victory", "drinkme", "spellshuffle", "spellpurge", "spellmeteor"];
    public static function key(medal:Int):Null<String> {
        var index = medal - 63802;
        return index >= 0 && index < keys.length ? keys[index] : null;
    }
}
