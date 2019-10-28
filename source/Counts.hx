package;

class Counts
{

	public static var counts:Map<String, Float>;

	public static function init():Void
	{
		counts = new Map<String, Float>();
	}

	public static function clear():Void
	{
		for (k in counts.keys())
		{
			counts.remove(k);
		}
	}

	public static function add(Count:String, Amount:Float):Void
	{
		var oldAmount:Float = 0;
		if (counts.exists(Count))
			oldAmount = counts.get(Count);
		counts.set(Count, oldAmount + Amount);
	}

	public static function increaseIfHigher(Count:String, Amount:Float):Void
	{
		var oldAmount:Float = -1;
		if (counts.exists(Count))
			oldAmount = counts.get(Count);
		if (Amount > oldAmount)
			counts.set(Count, Amount);
	}

}