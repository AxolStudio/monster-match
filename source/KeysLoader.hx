package;

#if macro
    import haxe.macro.Context;
    import haxe.macro.Expr;
    import sys.FileSystem;
#end

class KeysLoader
{
#if macro
    public static function build(Path:String):Array<haxe.macro.Expr.Field>
    {
        var keyMap:Array<Expr> = [];
        var fileNames:Array<String> = FileSystem.readDirectory(Path);
        for (fileName in fileNames)
        {
            if (!FileSystem.isDirectory(Path + fileName))
            {
                keyMap.push(macro $v{fileName} => $v{sys.io.File.getContent(Path + fileName)});
            }
        }

        var fields:Array<haxe.macro.Expr.Field> = Context.getBuildFields();

        fields.push({
            pos: Context.currentPos(),
            name: "keys",
            meta: null,
            kind: FieldType.FVar(macro:Map<String, String>, macro $a{keyMap}),
            doc: null,
            access: [Access.APublic, Access.AStatic]
        });

        return fields;
    }
#end
}
