from pathlib import Path
import subprocess,tempfile,shutil
root=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="monster-navigation-") as temp:
 for path in ["source/DesktopInput.hx","source/DesktopFocus.hx","tests/DesktopNavigationTest.hx","source/DesktopBoardCursor.hx","tests/DesktopBoardCursorTest.hx"]:
  shutil.copyfile(root/path,Path(temp)/Path(path).name)
 subprocess.run(["haxe","-cp",temp,"-main","DesktopNavigationTest","-D","desktop","-D","desktop_input_test","--interp"],check=True)

 for test in ["DesktopBoardCursorTest"]:
  subprocess.run(["haxe","-cp",temp,"-main",test,"-D","desktop","-D","desktop_input_test","--interp"],check=True)
