class LocalScoresTest {
    static function main() {
        var rows:Array<LocalScores.Score> = [];
        for (i in 0...15) rows = LocalScores.insert(rows, "AAA", i * 10);
        if (rows.length != 10 || rows[0].amount != 140 || rows[9].amount != 50)
            throw "Scores must retain the ten highest entries in descending order";
        var original = rows[0].amount;
        var next = LocalScores.insert(rows, "NEW", 999);
        if (rows[0].amount != original || next[0].initials != "NEW")
            throw "Inserting must preserve the original saved list";
        if (LocalScores.insert(null, "ONE", 1).length != 1) throw "First run must work";
        Sys.println("Local score tests passed");
    }
}
