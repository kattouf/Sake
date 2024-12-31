---
outline: deep
---

# Continuous Integration

## Prebuilding SakeApp Binary

To effectively use Sake in any CI environment, it's crucial to prebuild and reuse the SakeApp binary. This section guides you through prebuilding the binary, obtaining its path, caching it, and utilizing it with Sake command calls. If you don't know what is SakeApp, first refer to the [How It Works](/how-it-works.md) section.

### Steps to Prebuild SakeApp Binary

1. **Build the SakeApp Binary:**
   - Execute the following command to build the SakeApp binary:
     ```bash
     sake build
     ```
   - This command generates the binary at a specified path.

2. **Retrieve the Binary Path:**
   - Use this command to obtain the binary path:
     ```bash
     sake build --show-bin-path
     ```
   - The output will provide the path where the binary is stored.

3. **Utilize the Prebuilt Binary:**
   - Specify the path to the prebuilt binary using configuration options such as CLI, file, or environment variables. For instance, using a CLI command:
     ```bash
     sake run [command] --sake-app-prebuilt-binary-path somePath
     ```
   - Alternatively, set the path using an environment variable:
     ```bash
     export SAKE_APP_PREBUILT_BINARY_PATH=somePath
     ```
   - Or define it in the `.sake.yml` configuration file:
     ```yaml
     sake_app_prebuilt_binary_path: somePath
     ```

### Cache SakeApp prebuilt binary

To optimize the CI process, implement a caching strategy that balances the need to rebuild the SakeApp with the desire to maintain an up-to-date version.

- **Calculate Cache Hash:**
  - Use a hashing tool to generate a hash of the SakeApp files. This hash should reflect the current state of the files that affect the build.
  - Store this hash in your CI environment.

- **Skip Build if Unchanged:**
  - Before building, compare the current hash with the stored hash.
  - If they match, skip the build process to save time and resources.
  - If they differ, proceed with the build to ensure the SakeApp is up-to-date.

## Using `setup-sake` GitHub Action

The [`setup-sake`](https://github.com/kattouf/setup-sake) GitHub Action automates the setup and usage of the SakeApp binary in your GitHub Actions workflows, streamlining the process described above.

- It validates the provided Sake version to ensure it meets the minimum required version (0.2.4).
- It caches the prebuilt SakeApp binary for faster builds using the cache based on `SakeApp` files hash.

### Steps to Use `setup-sake`

1. **Add `setup-sake` to Your Workflow:**
   - Include the following in your GitHub Actions workflow file:
     ```yaml
     - name: Setup Sake
       uses: kattouf/setup-sake@v1
       with:
         sake-version: 'latest' # Optional: specify the version of Sake to install
         sake-config-path: './.sake.yml' # Optional: path to the Sake config file
         sake-app-path: './SakeApp' # Optional: path to the SakeApp (Default: './SakeApp')
     ```

2. **Ensure Swift is Installed:**
   - Ensure that the appropriate version of Swift is installed in your environment. The `setup-sake` action requires Swift to compile and run Sake commands. You can set up Swift using actions like `swift-actions/setup-swift` in your workflow:
     ```yaml
     - uses: swift-actions/setup-swift@v2
       with:
         swift-version: '5.10'
     ```

3. **Run Sake Commands:**
   - After setup, run Sake commands directly in your workflow:
     ```yaml
     - name: Run Sake Command
       run: sake <command>
     ```

### Full Example

```yaml
- name: Checkout Code
  uses: actions/checkout@v4

- name: Setup Swift
  uses: swift-actions/setup-swift@v2
  with:
    swift-version: '5.10'

- name: Setup Sake
  uses: kattouf/setup-sake@v1
  with:
    sake-version: 'latest'

- name: Run Your Sake Command - my-amazing-command
  run: sake my-amazing-command
```

By following these steps, you can efficiently integrate Sake into your CI processes, ensuring faster and more reliable builds.