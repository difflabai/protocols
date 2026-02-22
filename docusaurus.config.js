import {themes as prismThemes} from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Protocols',
  tagline: 'Open standards for AI development',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://protocols.difflab.ai',
  baseUrl: '/',

  organizationName: 'difflabai',
  projectName: 'protocols',

  onBrokenLinks: 'throw',

  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'throw',
    },
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          editUrl: 'https://github.com/difflabai/protocols/edit/main/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: 'Protocols',
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'protocolsSidebar',
            position: 'left',
            label: 'Protocols',
          },
          {
            href: 'https://github.com/difflabai/protocols',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'light',
        links: [],
        copyright: `Supported by <a href="https://difflab.ai" target="_blank" rel="noopener noreferrer"><img src="https://difflab.ai/images/url_light.svg" alt="Differential AI Lab" style="height: 1.4em; vertical-align: middle; margin-left: 0.3em;" /></a>`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
      },
    }),
};

export default config;
