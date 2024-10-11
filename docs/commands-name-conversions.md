# Command Name Conversions

Sake supports automatic conversion of command names to different case styles. You can specify the conversion strategy via configuration or environment variables.

Available conversion strategies:

- **keepOriginal**: Keeps the original case of the command names.
- **toSnakeCase**: Converts command names to `snake_case`.
- **toKebabCase**: Converts command names to `kebab-case`.

You can configure this by passing an argument to the `sake` commands, or by specifying it in the `.sake.yml` file:

```yaml
case_converting_strategy: toSnakeCase
```

The command name conversion is applied when execute or listing commands.
