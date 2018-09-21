import Navigator from './src/Navigator';
import Garden from './src/Garden';
import ReactRegistry from './src/ReactRegistry';
import router, { route } from './src/router';

const RESULT_OK = Navigator.RESULT_OK;
const RESULT_CANCEL = Navigator.RESULT_CANCEL;
const DARK_CONTENT = Garden.DARK_CONTENT;
const LIGHT_CONTENT = Garden.LIGHT_CONTENT;

export {
  Navigator,
  Garden,
  ReactRegistry,
  RESULT_OK,
  RESULT_CANCEL,
  DARK_CONTENT,
  LIGHT_CONTENT,
  router,
  route,
};
