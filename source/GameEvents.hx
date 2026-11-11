#if android
import axollib.AxolAPI;
import openfl.utils.ByteArray.ByteArrayData;

// Include only this game's existing Axol identifier, not unrelated key files.
@:file("keyfiles/axolapi") private class AxolEventKey extends ByteArrayData {}
#end

/** One semantic event fans out to independent services. Never blocks gameplay. */
class GameEvents {
    public static function initialize():Void {
        #if (android && !debug)
        if (!AxolAPI.initialized) {
            var bytes = new AxolEventKey();
            var key = StringTools.trim(bytes.readUTFBytes(bytes.length));
            if (key.length == 0) return;
            if (Globals.Save.data.guid == null || Globals.Save.data.guid == "") {
                Globals.Save.data.guid = AxolAPI.generateGUID();
                Globals.Save.flush();
            }
            AxolAPI.initialize(key, Globals.Save.data.guid);
            AxolAPI.initSave(Globals.Save.data.guid, Globals.Save);
        }
        #end
    }
    public static function track(name:String, amount:Int = 1, enabled:Bool = true):Void {
        #if (android && !debug)
        if (!enabled || !GameEventCatalog.accepts(name, amount)) return;
        try { if (AxolAPI.initialized) AxolAPI.sendEvent(name, amount); } catch (_:Dynamic) {}
        PlayServices.trackEvent(name, amount);
        #end
    }
}
