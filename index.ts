export * from './src/Navigator'
export * from './src/Garden'
export * from './src/ReactRegistry'
export * from './src/router'
export * from './src/hooks'

import { Navigator } from './src/Navigator'
import { Garden } from './src/Garden'

const RESULT_OK = Navigator.RESULT_OK
const RESULT_CANCEL = Navigator.RESULT_CANCEL
const DARK_CONTENT = Garden.DARK_CONTENT
const LIGHT_CONTENT = Garden.LIGHT_CONTENT

export { RESULT_OK, RESULT_CANCEL, DARK_CONTENT, LIGHT_CONTENT }
