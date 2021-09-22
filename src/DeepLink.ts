import { EventSubscription, Linking } from 'react-native'
import { router } from './router'

let _active = 0
let _uriPrefix: string = ''
let _hasHandleInitialURL = false
let _linkingSucscription: EventSubscription | undefined

function activate(uriPrefix: string) {
  if (!uriPrefix) {
    throw new Error('must pass `uriPrefix` when activate router.')
  }
  if (_active === 0) {
    _uriPrefix = uriPrefix
    if (!_hasHandleInitialURL) {
      _hasHandleInitialURL = true
      Linking.getInitialURL()
        .then(url => {
          if (url) {
            console.info(`deeplink:${url}`)
            const path = url.replace(_uriPrefix, '')
            return router.open(path)
          }
        })
        .catch(err => console.error('An error occurred', err))
    }
    _linkingSucscription = Linking.addEventListener('url', handleLinking)
  }
  _active++
}

function deactivate() {
  _active--
  if (_active === 0) {
    if (_linkingSucscription) {
      _linkingSucscription.remove()
      _linkingSucscription = undefined
    } else {
      Linking.removeEventListener('url', handleLinking)
    }
  }

  if (_active < 0) {
    _active = 0
  }
}

function handleLinking(event: { url: string }): void {
  console.info(`deeplink:${event.url}`)
  let path = event.url.replace(_uriPrefix, '')
  if (!path.startsWith('/')) {
    path = '/' + path
  }
  router.open(path)
}

export const DeepLink = {
  activate,
  deactivate,
}
