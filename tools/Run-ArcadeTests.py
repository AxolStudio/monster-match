from pathlib import Path
import subprocess,json,os
root=Path(__file__).resolve().parents[1]
out=root/'diagnostics';out.mkdir(exist_ok=True)
exe=root/'export/arcade-tests/windows/bin/MonsterArcadeRegression.exe'
for device in [None,'keyboard','gamepad']:
 name=device or 'native';report=out/(name+'.json')
 for path in [report,Path(str(report)+'.progress'),Path(str(report)+'.heartbeat')]:
  if path.exists():path.unlink()
 env=dict(os.environ,MONSTER_TEST_RESULT=str(report))
 env.pop('MONSTER_TEST_DEVICE',None)
 if device:env['MONSTER_TEST_DEVICE']=device
 try:
  result=subprocess.run([str(exe)],cwd=exe.parent,env=env,timeout=240,capture_output=True,text=True)
  (out/(name+'.log')).write_text(result.stdout+'\n'+result.stderr,encoding='utf-8')
 except subprocess.TimeoutExpired as error:
  (out/(name+'.log')).write_text('Timed out after 240 seconds\n'+str(error.stdout)+'\n'+str(error.stderr),encoding='utf-8')
  raise
 assert report.exists(),'Missing runtime report; exit='+str(result.returncode)
 data=json.loads(report.read_text(encoding='utf-8'));print(json.dumps(data,indent=2))
 assert result.returncode==0 and data.get('passed') is True,'Runtime failed; exit='+str(result.returncode)
 if device:assert data.get('exitRequested') is True,'Actual OS Exit was not reached'
 else:assert data.get('failures')==0
