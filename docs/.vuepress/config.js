module.exports = {
  title: 'Hybrid Navigation',
  description: 'hybrid-navitation 文档',
  base: '/rn/hybrid-navigation/',
  themeConfig: {
    home: '/',
    lastUpdatedText: '上次更新',
    sidebarDepth: 2,
    contributors: false,
    repo: 'https://github.com/listenzz/hybrid-navigation',
    editLink: false,
    docsBranch: 'master',
    navbar: [
      { text: '首页', link: '/', },
      { text: '博客', link: 'https://todoit.tech/', target: '_self', rel: '' },
    ],
    sidebar: {
      '/': [
        'integration-react',
        'integration-native',
        'navigation',
        'style',
        'pass-and-return-value',
        'lifecycle',
        'deeplink',
        'custom-tabbar',
        'qa',
      ]
    }
  },

  markdown: {
    code: {
      lineNumbers: false
    }
  },
}