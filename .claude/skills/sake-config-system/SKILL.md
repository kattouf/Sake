---
name: sake-config-system
description: Use when working on Sake configuration — .sake.yml, environment variables, CLI options, ConfigManager, ConfigResolver, or adding new config options.
---

# Sake Configuration System

## Resolution Cascade

Priority (highest first): **CLI args → ENV vars → .sake.yml → defaults**

## Config Types

```
CLIConfig         → from ArgumentParser options (CommonOptions, CommandRelatedCommonOptions)
ENVConfig         → from ProcessInfo.processInfo.environment
FileConfig        → from .sake.yml via Yams
Config            → resolved final config
ConfigResolver    → merge logic
ConfigManager     → orchestrates loading + resolution
```

## Available Options

| Option | CLI | ENV | .sake.yml | Default |
|--------|-----|-----|-----------|---------|
| Config path | `--config-path` | `SAKE_CONFIG_PATH` | — | `.sake.yml` |
| SakeApp path | `--sake-app-path` | `SAKE_APP_PATH` | `sake_app_path` | `./SakeApp` |
| Prebuilt binary | `--sake-app-prebuilt-binary-path` | `SAKE_APP_PREBUILT_BINARY_PATH` | `sake_app_prebuilt_binary_path` | nil |
| Case strategy | `--case-converting-strategy` | `SAKE_CASE_CONVERTING_STRATEGY` | `case_converting_strategy` | `keepOriginal` |
| Experimental | — | `SAKE_EXPERIMENTAL_FEATURES` | — | disabled |

**Mutual exclusion:** `sakeAppPath` and `sakeAppPrebuiltBinaryPath` cannot both be set.

## .sake.yml Format

```yaml
case_converting_strategy: toSnakeCase  # keepOriginal | toSnakeCase | toKebabCase
sake_app_path: SakeApp
sake_app_prebuilt_binary_path: .build/prebuilt/SakeApp
```

Parsed with Yams library. `FileConfig` is `Decodable`.

## Case Converting Strategies

```swift
enum CaseConvertingStrategy: String, CaseIterable, ExpressibleByArgument, Decodable, Sendable {
    case keepOriginal   // helloWorld → helloWorld
    case toSnakeCase    // helloWorld → hello_world
    case toKebabCase    // helloWorld → hello-world
}
```

Applied by `CommandNameCaseConverter` to command names when listing/running.

## Error Handling

```swift
ConfigManager.Error:
  .configFileNotFound(configPath:)
  .configFileCorrupted(configPath:, error:)

ConfigResolver.Error:
  .mutualExclusiveOptions(["sakeAppPath", "sakeAppPrebuiltBinaryPath"])
```

## Key Files

```
Sources/SakeCLILibrary/Config/Config.swift         — Config struct + defaults
Sources/SakeCLILibrary/Config/CLIConfig.swift       — from CLI args
Sources/SakeCLILibrary/Config/ENVConfig.swift        — from env vars
Sources/SakeCLILibrary/Config/FileConfig.swift       — from .sake.yml
Sources/SakeCLILibrary/Config/ConfigManager.swift    — orchestration + resolver
Sources/SakeCLILibrary/CommonOptions.swift           — ArgumentParser option groups
Sources/SakeShared/CaseConvertingStrategy.swift      — enum
```
