"""Compile the real GameEvents class against inert service boundaries.

This test runs no game, reads no private key files, and makes no network calls.
"""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
fixtures = {
    'axollib/AxolAPI.hx': '''package axollib;
class AxolAPI {
 public static var initialized = true;
 public static var calls = 0;
 public static function initialize(key:String, ?guid:String):Void { calls++; }
 public static function initSave(guid:String, save:Dynamic):Void { calls++; }
 public static function generateGUID():String { return "test-guid"; }
 public static function sendEvent(name:String, amount:Int):Void { calls++; }
}''',
    'openfl/utils/ByteArray.hx': '''package openfl.utils;
class ByteArrayData {
 public var length = 0;
 public function new() {}
 public function readUTFBytes(length:Int):String { return ""; }
}''',
    'Globals.hx': '''class Globals { public static var Save:Dynamic = {data: {guid: "test-guid"}, flush: function() {}}; }''',
    'PlayServices.hx': '''class PlayServices {
 public static var calls = 0;
 public static function trackEvent(name:String, amount:Int):Void { calls++; }
}''',
    'DesktopGameEventsTest.hx': '''class DesktopGameEventsTest {
 static function main() {
  GameEvents.initialize();
  GameEvents.track("game_started");
  if (axollib.AxolAPI.calls != 0 || PlayServices.calls != 0)
   throw "Android-only event reporting reached desktop services";
  trace("Desktop event boundary passed");
 }
}''',
}
with tempfile.TemporaryDirectory(prefix='monster-desktop-events-') as temp:
    base = Path(temp)
    for name, contents in fixtures.items():
        target = base / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(contents, encoding='utf-8')
    for name, relative in [('GameEvents.hx', 'source/GameEvents.hx'), ('GameEventCatalog.hx', 'core/GameEventCatalog.hx')]:
        (base / name).write_bytes((root / relative).read_bytes())
    for defines in [[], ['-D', 'debug']]:
        subprocess.run(['haxe', '-cp', temp, '-main', 'DesktopGameEventsTest', '--interp', *defines], cwd=temp, check=True)
print('Desktop release and debug event boundaries passed')
