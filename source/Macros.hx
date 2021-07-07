package;

#if macro
    class Macros
    {
    public static macro function getKey(Flag:String):haxe.macro.Expr
    {
        if (haxe.macro.Context.defined(Flag))
        {
            return macro $v{haxe.macro.Context.definedValue(Flag)};
        }
        else
        {
            return macro $v{""};
        }
    }
    }
#end
