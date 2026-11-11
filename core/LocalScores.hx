typedef Score = {initials:String, amount:Int};

/** Offline Android scores do not depend on the legacy web service. */
class LocalScores {
    public static function insert(previous:Array<Score>, initials:String, amount:Int):Array<Score> {
        var rows = previous == null ? [] : previous.copy();
        rows.push({initials: initials, amount: amount});
        rows.sort((a, b) -> a.amount == b.amount ? 0 : (a.amount > b.amount ? -1 : 1));
        return rows.slice(0, 10);
    }
}
