import { EmitterSubscription, Linking } from 'react-native'
import { router } from './router'

class DeepLinkImpl {
  private active = 0
  private uriPrefix = ''
  private hasHandleInitialURL = false
  private subscription: EmitterSubscription | null = null

  activate(uriPrefix: string) {
    if (!uriPrefix) {
      throw new Error('must pass `uriPrefix` when activate router.')
    }
    if (this.active === 0) {
      this.uriPrefix = uriPrefix
      if (!this.hasHandleInitialURL) {
        this.hasHandleInitialURL = true
        Linking.getInitialURL()
          .then(url => {
            if (url) {
              console.info(`deeplink:${url}`)
              const path = url.replace(this.uriPrefix, '')
              return router.open(path)
            }
          })
          .catch(err => console.error('An error occurred', err))
      }
      this.subscription = Linking.addEventListener('url', this.handleLinking)
    }
    this.active++
  }

  deactivate() {
    this.active--
    if (this.active === 0) {
      if (this.subscription) {
        this.subscription.remove()
        this.subscription = null
      } else {
        Linking.removeEventListener('url', this.handleLinking)
      }
    }

    if (this.active < 0) {
      this.active = 0
    }
  }

  private handleLinking = (event: { url: string }) => {
    console.info(`deeplink:${event.url}`)
    let path = event.url.replace(this.uriPrefix, '')
    if (!path.startsWith('/')) {
      path = '/' + path
    }
    router.open(path)
  }
}

export const DeepLink = new DeepLinkImpl()
