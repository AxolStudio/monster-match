package;

import haxe.Json;
import lime.utils.Assets;
import openfl.utils.Object;

class MonsterData
{

	private static var data:Array<MonsterData>;

	public var name:String = "";
	public var id:Int = -1;
	public var hp:Int = 0;
	public var att:Int = 0;
	public var def:Int = 0;
	public var satt:Int = 0;
	public var sdef:Int = 0;
	public var color:String;

	public function new(Name:String, Id:Int, Hp:Int, Att:Int, Def:Int, SAtt:Int, SDef:Int, Color:String)
	{
		name = Name;
		id = Id;
		hp = Hp;
		att = Att;
		def = Def;
		satt = SAtt;
		sdef = SDef;
		color = Color;
	}

	public static function initData():Void
	{
		data = [];

		var json:{monsters:Array<Object>} = Json.parse(Assets.getText(AssetPaths.monsters__json));
		for (m in json.monsters)
			data.push(new MonsterData(m.name, Std.parseInt(m.id), Std.parseInt(m.hp), Std.parseInt(m.att), Std.parseInt(m.def), Std.parseInt(m.satt), Std.parseInt(m.sdef), m.color));

	}

	public static function getFromID(Id:Int):MonsterData
	{
		for (d in data)
			if (d.id == Id)
				return new MonsterData(d.name, d.id, d.hp, d.att, d.def, d.satt, d.def, d.color);
		return null;
	}
	public static function getFromName(Name:String):MonsterData
	{
		for (d in data)
			if (d.name == Name)
				return new MonsterData(d.name, d.id, d.hp, d.att, d.def, d.satt, d.def, d.color);
		return null;
	}

}