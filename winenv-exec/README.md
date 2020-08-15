# winenv-exec

### Usage:
```
> winenv-exec --help
Usage: winenv-exec [OPTIONS]

Optional arguments:
  -h, --help           print help message
  -c, --config CONFIG  path to config to instantiate
```

### ./example_config.json:
```json
{
    "activationHooks": [],
    "filesystem": []
}
```

```
> winenv-exec --config example_config.json
```
