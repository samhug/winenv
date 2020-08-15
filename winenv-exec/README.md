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
    "activationHooks": [
      {
        "args": [
          "-Command",
          "Write-Output 'Hello World!'"
        ],
        "command": "powershell.exe"
      },
    ],
    "filesystem": [
      {
        "ensure": "Present",
        "name": "hosts",
        "path": "c:/windows/system32/drivers/etc",
        "text": "0.0.0.0 www.facebook.com"
      },
    ]
}
```

```
> winenv-exec --config example_config.json
```
