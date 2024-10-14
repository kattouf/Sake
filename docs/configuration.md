---
outline: deep
---

# Configuration

Sake provides flexible options for configuration, which can be set via:

1. **CLI arguments**: The highest priority, passed directly when running a command.
2. **Environment variables**: Can be set in your system or project environment.
3. **Configuration file (`.sake.yml`)**: Defines default settings for your project.

### CLI arguments

Sake allows configuration via CLI arguments, which have the highest priority. You can see all available options by running:

```bash
sake [command] --help
```

### Environment variables

Sake also supports configuration via environment variables. The following environment variables are available:

- **`SAKE_CONFIG_PATH`**: Path to the `.sake.yml` file.
- **`SAKE_APP_PATH`**: Path to the SakeApp package.

For example, you can set these variables in your environment:

```bash
export SAKE_CONFIG_PATH="/path/to/.sake.yml"
export SAKE_APP_PATH="/path/to/SakeApp"
```

### Configuration file (.sake.yml)

You can define configuration options in the `.sake.yml` file, located in the root of your project. For example:

```yaml
case_converting_strategy: toSnakeCase # available values: keepOriginal, toSnakeCase, toKebabCase
sake_app_path: some/path
```

### Resolution order

Configuration is resolved in the following order:

1. **CLI arguments**: If passed, CLI arguments will override any other settings.
2. **Environment variables**: If CLI arguments are not provided, Sake will check for environment variables.
3. **Configuration file**: If neither CLI arguments nor environment variables are present, Sake will fall back to the `.sake.yml` file.
