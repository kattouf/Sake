# Installation

::: info Requirements
macOS 13+ and Linux are supported and require **Swift 6.1** or higher.
:::

### Package Managers

::: code-group

```sh [Homebrew]
brew install kattouf/sake/sake
```

```sh [Mint]
mint install kattouf/Sake
```

```sh [Mise (CLI)]
# Option 1: Using UBI backend (faster to install, because it uses prebuilt binaries)
mise use -g "ubi:kattouf/Sake[exe=sake]"
# Option 2: Using SPM backend (takes longer to install, because it builds the package from source)
mise use -g spm:kattouf/Sake
```

```toml [Mise (toml config)]
[tools]
# Option 1: Using UBI backend (faster to install, because it uses prebuilt binaries)
"ubi:kattouf/Sake" = { version = "latest", exe = "sake" }
# Option 2: Using SPM backend (takes longer to install, because it builds the package from source)
"spm:kattouf/Sake" = "latest"
```

:::

### Manual Installation

Download the binary for your platform from the [releases page](https://github.com/kattouf/Sake/releases), and place it in your executable path.
