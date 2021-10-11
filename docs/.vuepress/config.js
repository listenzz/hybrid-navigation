module.exports = {
  title: 'Hybrid Navigation',
  description: 'hybrid-navitation 文档',
  base: '/hybrid-navigation/',
  themeConfig: {
    home: '/',
    lastUpdatedText: '上次更新',
    sidebarDepth: 2,
    contributors: false,
    repo: 'https://github.com/listenzz/hybrid-navigation',
    editLink: false,
    docsBranch: 'master',
    navbar: [
      { text: '文档', link: '/', },
      { text: 'React Native 入门指南', link: 'https://todoit.tech/rn/' },
      // { text: 'Kubernetes', link: '/k8s/' },
      // { text: '关于', link: 'https://todoit.tech/about/', target:'_self', rel:'' },
      // { text: '关于', link: '/about' },
    ],
    sidebar: {
      '/': [
        'integration-react',
        'integration-native',
        'navigation',
        'pass-and-return-value',
        'lifecycle',
        'style',
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