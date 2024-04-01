package;

import haxe.Json;
import lime.utils.Assets;
import openfl.utils.Object;

class HeroData
{
    private static var data:Array<HeroData>;

    public var id:Int = -1;
    public var hp:Int = 0;
    public var att:Int = 0;
    public var def:Int = 0;
    public var satt:Int = 0;
    public var sdef:Int = 0;

    public function new(Id:Int, Hp:Int, Att:Int, Def:Int, SAtt:Int, SDef:Int)
    {
        id = Id;
        hp = Hp;
        att = Att;
        def = Def;
        satt = SAtt;
        sdef = SDef;
    }

    public static function initData():Void
    {
        data = [];

        var json:
            {heroes:Array<Object>} = Json.parse(Assets.getText("assets/data/heroes.json"));
        for (h in json.heroes)
            data.push(new HeroData(Std.parseInt(h.id), Std.parseInt(h.hp), Std.parseInt(h.att), Std.parseInt(h.def), Std.parseInt(h.satt),
                Std.parseInt(h.sdef)));
    }

    public static function getFromID(Id:Int):HeroData
    {
        for (d in data)
            if (d.id == Id)
                return new HeroData(d.id, d.hp, d.att, d.def, d.satt, d.sdef);
        return null;
    }

    public static function count():Int
    {
        return data.length;
    }
}
