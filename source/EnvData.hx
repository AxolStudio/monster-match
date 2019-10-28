package;
import haxe.Json;
import lime.utils.Assets;
import openfl.utils.Object;

class EnvData
{

	private static var data:Array<EnvData>;

	public var name:String = "";
	public var id:Int = -1;
	public var monsters:Array<String>;

	public function new(Name:String, Id:Int, Monsters:Array<String>)
	{
		name = Name;
		id = Id;
		monsters = Monsters.copy();
	}

	public static function initData():Void
	{
		data = [];

		var json:{environments:Array<Object>} = Json.parse(Assets.getText(AssetPaths.environments__json));
		for (e in json.environments)
			data.push(new EnvData(e.name, Std.parseInt(e.id), e.monsters));
	}

	public static function getFromID(Id:Int):EnvData
	{
		for (d in data)
		{
			if (d.id == Id)
			{
				return new EnvData(d.name, d.id, d.monsters);
			}
		}
		return null;
	}

	public static function getFromName(Name:String):EnvData
	{
		for (d in data)
		{
			if (d.name == Name)
			{
				return new EnvData(d.name, d.id, d.monsters);
			}
		}
		return null;
	}

	public static function count():Int
	{
		return data.length;
	}

}