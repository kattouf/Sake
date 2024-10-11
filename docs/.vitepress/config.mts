import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Sake",
  description: "Manage project commands using Swift",
  head: [["link", { rel: "icon", href: "/img/favicon.ico" }]],
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    siteTitle: "Sake 🍶",
    nav: [
      { text: "Home", link: "/" },
      // { text: "Documentation", link: "/getting-started" },
    ],

    sidebar: [
      {
        text: "General",
        items: [
          { text: "About", link: "/about" },
          { text: "Installation", link: "/installation" },
          { text: "Getting Started", link: "/getting-started" },
          { text: "Configuration", link: "/configuration" },
        ],
      },
      {
        text: "Defining Commands",
        items: [
          { text: "Basic Rules", link: "/commands-basic-rules" },
          { text: "Dependencies", link: "/commands-dependencies" },
          {
            text: "Conditional execution",
            link: "/commands-conditional-execution",
          },
          { text: "Grouping", link: "/command-grouping" },
          { text: "Command Name Converions", link: "/commands-name-conversions" }
        ],
      },
      {
        text: "Cookbook",
        items: [],
      },
      {
        items: [
          { text: "How It Works", link: "/how-it-works" },
          { text: "Troubleshooting", link: "/troubleshooting" },
        ],
      },
    ],

    socialLinks: [{ icon: "github", link: "https://github.com/kattouf/Sake" }],
  },
});
