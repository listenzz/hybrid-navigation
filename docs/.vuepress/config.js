import { defaultTheme } from 'vuepress'

module.exports = {
  title: 'Hybrid Navigation',
  description: 'hybrid-navitation 文档',
  base: '/rn/hybrid-navigation/',
  theme: defaultTheme({
    home: '/',
    lastUpdatedText: '上次更新',
    contributors: false,
    repo: 'https://github.com/listenzz/hybrid-navigation',
    editLink: false,
    docsBranch: 'master',
    navbar: [
      { text: '首页', link: '/', },
      { text: 'React Native 开发指南', link: 'https://todoit.tech/' },
    ],
    sidebarDepth: 3,
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
  }),
  
  markdown: {
    code: {
      lineNumbers: false
    },
    headers: {
      level: [2, 3, 4]
    }
  },
}