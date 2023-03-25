# Reproduction of pytype import-error for `pydantic.BaseModel`

```
/opt/venv/bin/python -m pytype.single --imports_info /tmp/service-python-01/.pytype/imports/service.imports --module-name service --platform linux -V 3.10 -o /tmp/service-python-01/.pytype/pyi/service.pyi --analyze-annotated --nofail --quick /tmp/service-python-01/service.py
File "/tmp/service-python-01/service.py", line 11, in <module>: Can't find module 'pydantic.BaseModel'. [import-error]
```

# Related Issues

- https://github.com/google/pytype/issues/1105

# Usage

1. Build dev image with `make image/dev`
2. Enter dev image with `make bash` and run all commands needed therein
3. Within the shell run `poetry install` to install all depencencies
4. Run `poetry run pytype example.py` to type-check example.py

> :warning: Tested on a Linux setup. The Makefile relies on some *nix utils such as `id` (used for assuming the host user identity to simplify file ownership management), `shell` (used for shell expansion) and `realpath` (to extract the absolute paths on the host-side for volume mounting). Anticipating that this may work on BSD-likes and WSL but I don't have the means to test this.
