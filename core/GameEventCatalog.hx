/** Stable names shared by Axol, Play Games Events and Game Stats schemas. */
class GameEventCatalog {
    public static final names = ["game_started", "monster_summoned", "hero_defeated", "spell_cast", "game_completed", "victory"];
    public static function accepts(name:String, amount:Int):Bool {
        return amount > 0 && names.indexOf(name) >= 0;
    }
}
