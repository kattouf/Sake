---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: Sake 🍶
  text: Manage project commands using Swift
  tagline: Inspired by Make, built for convenience
  image:
    dark: /img/hello_dark.png
    light: /img/hello_light.png
    alt: Hello World!
  actions:
    - theme: brand
      text: Install
      link: /installation
    - theme: alt
      text: Documentation
      link: /getting-started

features:
  - title: ⚡ Swift-based
    details: Define and manage commands directly in Swift, with type safety and autocompletion.
    
  - title: 🔗 Command Dependencies
    details: Ensure commands run in the correct order with automatic dependency handling.
    
  - title: ⏩ Conditional Execution
    details: Skip commands based on custom conditions.
    
  - title: 🛠️ Flexible Configuration
    details: Configure via CLI arguments, environment variables, or YAML files.
    
  - title: 📜 Command Listing
    details: List all available commands with descriptions.
    
  - title: 🔌 Extensible
    details: Extend functionality with additional Swift libraries or tools.
---
