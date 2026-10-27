import os
import sys
import subprocess

env = os.environ.copy()
project_root = r"d:\Projects\gymlvl"
tmp_dir = os.path.join(project_root, "tmp")
localappdata = os.path.join(tmp_dir, "localappdata")
appdata = os.path.join(tmp_dir, "appdata")
os.makedirs(localappdata, exist_ok=True)
os.makedirs(appdata, exist_ok=True)

env['LOCALAPPDATA'] = localappdata
env['APPDATA'] = appdata
env['USERPROFILE'] = tmp_dir
env['DART_TELEMETRY_DISABLED'] = '1'
env['FLUTTER_SUPPRESS_ANALYTICS'] = 'true'

args = sys.argv[1:] if len(sys.argv) > 1 else ['test/candy_ui_test.dart']
cmd = f'flutter test {" ".join(args)} --no-pub'
print(f"Running: {cmd}")
proc = subprocess.run(cmd, cwd=os.path.join(project_root, "app"), env=env, shell=True)
sys.exit(proc.returncode)
