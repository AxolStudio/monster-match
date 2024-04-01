package;

import haxe.Json;
import lime.utils.Assets;
import openfl.utils.Object;

class MonsterData
{
    private static var data:Array<MonsterData>;

    private static var monstersById:Map<Int, Int>;
    private static var monstersByName:Map<String, Int>;

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

    public function copy():MonsterData
    {
        return new MonsterData(name, id, hp, att, def, satt, sdef, color);
    }

    public static function initData():Void
    {
        data = [];

        var json:
            {monsters:Array<Object>} = Json.parse(Assets.getText("assets/data/monsters.json"));
        for (m in json.monsters)
            data.push(new MonsterData(m.name, Std.parseInt(m.id), Std.parseInt(m.hp), Std.parseInt(m.att), Std.parseInt(m.def), Std.parseInt(m.satt),
                Std.parseInt(m.sdef), m.color));
        monstersById = [];
        monstersByName = [];
        for (id in 0...data.length)
        {
            monstersById.set(data[id].id, id);
            monstersByName.set(data[id].name, id);
        }
    }

    public static function getFromID(Id:Int):Null<MonsterData>
    {
        if (monstersById.exists(Id))
        {
            var m:Int = monstersById.get(Id);
            return data[m].copy();
        }
        return null;
    }

    public static function getFromName(Name:String):Null<MonsterData>
    {
        if (monstersByName.exists(Name))
        {
            var m:Int = monstersByName.get(Name);
            return data[m].copy();
        }
        return null;
    }
}
