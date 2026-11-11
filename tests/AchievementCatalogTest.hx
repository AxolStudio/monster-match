class AchievementCatalogTest {
    static function main() {
        var expected = ['gardens','dungeons','catacomb','viaduct','ruins','ramparts','sanctum','victory','drinkme','spellshuffle','spellpurge','spellmeteor'];
        for (i in 0...expected.length)
            if (AchievementCatalog.key(63802+i) != expected[i]) throw 'Wrong original medal mapping: '+(63802+i);
        if (AchievementCatalog.key(0) != null || AchievementCatalog.key(63814) != null) throw 'Unknown achievement accepted';
        trace('Achievement event mappings passed');
    }
}
