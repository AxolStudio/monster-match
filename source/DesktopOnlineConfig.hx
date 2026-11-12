#if desktop
/** Existing client-distributed game identifier from public Globals source at349f81c.
    Parent verified equality with current specific configuration without disclosing it.
    No keyfiles directory enumeration or credential dependency in desktop builds. */
class DesktopOnlineConfig {
 public static function gameKey():String {
  #if arcade_regression
  return "";
  #else
  return "AA9C25D6369E4EAFA39E6369AF12DF6D";
  #end
 }
}
#end
