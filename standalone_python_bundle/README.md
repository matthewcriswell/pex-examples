# Standalone Python Examples
An example of how to bootstrap a standalone static Python runtime capable of running pre-built PEX files.  This is a more complex approach than using PyInstaller, but the advantage is that you can  modify the contents of a PEX file in the field.  This extra flexibility may be worth the compexity, especially in situations where the Python code is still under heavy development.

## Building a PEX

Activate a virtualenv and install PEX
```bash
python3 -m venv pex_build
source pex_build/bin/activate
pip install -r pex_build.requirements.txt 
PEX_VERBOSE=1 pex --python $HOME/tools/python/bin/python  --python-shebang $HOME/tools/python/bin/python  -r requirements.txt -o utils.pex
```

## Bootstrapping the environment
To setup a standalone Python 3.11 on a target environment run the following script
```bash
bootstrap-311.sh
```

You can then attempt to set this in your path by sourcing the `tools.env` file:
```bash
source tools.env
``` 

If all went well you should see that you can build and run PEX files which run with the 3.11 runtime:
```bash
matt@lima-default:~/github/pex-examples/standalone_python_bundle$ ./utils.pex -V
Python 3.11.12
```

You can now utilize the bundled packages in the PEX without having to install anything else:
```bash
matt@lima-default:~/github/pex-examples/standalone_python_bundle$ ./utils.pex check_container_runtime.py 
✔ nerdctl is available; proceeding…
```

Here we used python_on_whales to check for `nerdctl` or `docker` -- and we see on a local Lima environment the user is able to run nerdctl
