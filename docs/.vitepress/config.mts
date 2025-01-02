import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  // base: '/Sake/', # uncomment to use with github pages
  title: "Sake",
  description: "Manage project commands using Swift",
  head: [["link", { rel: "icon", href: "/favicon.ico" }]],
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    search: {
      provider: 'local'
    },
    siteTitle: "Sake 🍶",
    nav: [
      { text: "Home", link: "/" },
      { text: "Docs", link: "/about" }
    ],
    sidebar: [
      {
        text: "General",
        items: [
          { text: "About", link: "/about" },
          { text: "Installation", link: "/installation" },
          { text: "Getting Started", link: "/getting-started" },
          { text: "Editing Commands", link: "/editing-commands" },
          { text: "Passing Arguments", link: "/passing-arguments" },
          { text: "Configuration", link: "/configuration" },
          { text: "Shell Completion", link: "/shell-completion" },
          { text: "Continuous Integration", link: "/continuous-integration" },
        ],
      },
      {
        text: "Defining Commands",
        items: [
          { text: "Basic Rules", link: "/commands-basic-rules" },
          { text: "Run Context", link: "/commands-run-context" },
          { text: "Dependencies", link: "/commands-dependencies" },
          {
            text: "Conditional execution",
            link: "/commands-conditional-execution",
          },
          { text: "Grouping", link: "/commands-grouping" },
          { text: "Command Name Converions", link: "/commands-name-conversions" },
          { text: "Sharing Data Between Commands", link: "/sharing-data-between-commands" },
          { text: "Interruption Handling", link: "/interruption-handling" },
        ],
      },
      {
        text: "Advanced Usage",
        items: [
          { text: "Extensibility of SakeApp", link: "/advanced-extensibility-of-sakeapp" },
          { text: "Argument Parsing", link: "/advanced-argument-parsing" },
          { text: "CLI Tools Running", link: "/advanced-cli-tools-running" },
          { text: "Example", link: "/advanced-usage-example" },
        ],
      },
      {
        items: [
          { text: "How It Works", link: "/how-it-works" },
          { text: "Limitations", link: "/limitations" },
          { text: "Troubleshooting", link: "/troubleshooting" },
          { text: "Contribution Guide", link: "/contribution-guide" },
        ],
      },
    ],
    socialLinks: [{ icon: "github", link: "https://github.com/kattouf/Sake" }],
  },
});
