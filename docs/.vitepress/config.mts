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
          { text: "Command Name Converions", link: "/commands-name-conversions" }
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
        ],
      },
    ],

    socialLinks: [{ icon: "github", link: "https://github.com/kattouf/Sake" }],
  },
});
