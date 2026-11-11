class GameEventCatalogTest {
    static function main() {
        for (name in GameEventCatalog.names) if (!GameEventCatalog.accepts(name, 1)) throw name;
        if (GameEventCatalog.accepts("unknown", 1) || GameEventCatalog.accepts("victory", 0)
            || GameEventCatalog.accepts("victory", -1)) throw "Invalid event accepted";
        if (GameEventCatalog.names.length != 6) throw "Schema changed";
        trace("Game event catalog passed");
    }
}
