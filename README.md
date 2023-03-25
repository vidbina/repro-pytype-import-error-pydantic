# Reproduction of pytype import-error for `pydantic.BaseModel`

When using pydantic with pytype, one may encounter `import-error` and `base-class-error` issues that I've cataloged here as a minimal reproducible setup for future evaluation (I may just move on to another typechecker for now and come back to this when I have time and headspace).

```
/opt/venv/bin/python -m pytype.single --imports_info /tmp/service-python-01/.pytype/imports/service.imports --module-name service --platform linux -V 3.10 -o /tmp/service-python-01/.pytype/pyi/service.pyi --analyze-annotated --nofail --quick /tmp/service-python-01/service.py
File "/tmp/service-python-01/service.py", line 11, in <module>: Can't find module 'pydantic.BaseModel'. [import-error]
```

# Usage

1. Build dev image with `make image/dev`
2. Enter dev image with `make bash` and run all commands needed therein
3. Within the shell, run `poetry install` to install all depencencies
4. Within the shell, run `poetry run pytype FILE` to type-check FILE
   - You can also run `poetry run pytype -v 2 FILE` to increase the verbosity of the type-checking run

> :warning: Tested on a Linux setup. The Makefile relies on some *nix utils such as `id` (used for assuming the host user identity to simplify file ownership management), `shell` (used for shell expansion) and `realpath` (to extract the absolute paths on the host-side for volume mounting). Anticipating that this may work on BSD-likes and WSL but I don't have the means to test this.

# Cases

Some cases are outlined below. Write the code from the snippet into problem.py to then run type checker over that file (by running `poetry run pytype -v 2 problem.py` with the shell where you have poetry configured).

## import-error

Pytype fails with an `import-error` when it encounters `pydantic.BaseModel`:

```
/tmp/home/.cache/pypoetry/virtualenvs/repro-pytype-import-error-pydantic-1maHa21D-py3.10/bin/python -m pytype.single --imports_info /tmp/target/.pytype/imports/problem.imports --module-name problem --platform linux -V 3.10 -o /tmp/target/.pytype/pyi/problem.pyi --analyze-annotated --nofail --quick /tmp/target/problem.py
File "/tmp/target/problem.py", line 1, in <module>: Can't find module 'pydantic.BaseModel'. [import-error]

For more details, see https://google.github.io/pytype/errors.html#import-error
```

Observe how we import `BaseModel` and `Field` from `pydantic` on line 1 in the snippet below:

```python
from pydantic import BaseModel, Field

class Thing(BaseModel):
    name: str = Field(example="Something fun")

if __name__ == "__main__":
    print("here is trouble")
```

A workaround suggested in https://github.com/google/pytype/issues/1105#issue-1102450867 is to just `import pydantic` and use the longer-form model references.

```python
import pydantic

class Thing(pydantic.BaseModel):
    name: str = pydantic.Field(example="Something fun")

if __name__ == "__main__":
    print("here is trouble")
```

🚨 Note that disabling the import error as demonstrated below is quite dangerous as it disables typechecking on the offending resource. In the spinnet below, notice how the type `Bogus` is imported although it doesn't exist. This `Bogus` class is used as part of the definition of `Thing` and silencing pytype on the import-error produces no warning of any follow-on issues.

```python
from pydantic import BaseModel, Field, Bogus  # pytype: disable=import-error

class Thing(BaseModel):
    name: str = Field(example="Something fun")
    other: str = Bogus(warning="we've basically told pytype to stop helping")

if __name__ == "__main__":
    print("here is trouble")
```

## base-class-error

When only importing `pydantic.BaseModel` (and not conflating the setup with other imports from pydantic), Pytype fails with a `base-class-error`:

```
/tmp/home/.cache/pypoetry/virtualenvs/repro-pytype-import-error-pydantic-1maHa21D-py3.10/bin/python -m pytype.single --imports_info /tmp/target/.pytype/imports/problem.imports --module-name problem --platform linux -V 3.10 -o /tmp/target/.pytype/pyi/problem.pyi --analyze-annotated --nofail --quick /tmp/target/problem.py
File "/tmp/target/problem.py", line 3, in <module>: Invalid base class: <instance of module> [base-class-error]

For more details, see https://google.github.io/pytype/errors.html#base-class-error
```

The offending snippet is listed below:

```python
from pydantic import BaseModel

class Thing(BaseModel):
    name: str = "Something fun"

if __name__ == "__main__":
    print("here is trouble")
```

and a current workaround would just be to silence pytype on the base class issue:

```python
from pydantic import BaseModel

class Thing(BaseModel):  # pytype: disable=base-class-error
    name: str = "Something fun"

if __name__ == "__main__":
    print("here is trouble")
```

# Related Issues

- https://github.com/google/pytype/issues/1105
