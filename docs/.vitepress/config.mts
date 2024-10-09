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
        text: "Documentation",
        items: [
          { text: "Installation", link: "/installation" },
          { text: "Getting Started", link: "/getting-started" },
        ],
      },
    ],

    socialLinks: [{ icon: "github", link: "https://github.com/kattouf/Sake" }],
  },
});
