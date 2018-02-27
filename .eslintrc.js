// http://eslint.org/docs/user-guide/configuring

module.exports = {
  root: true,
  parser: "babel-eslint",
  parserOptions: {
    ecmaVersion: 6,
    sourceType: "module",
    ecmaFeatures: {
      jsx: true,
      experimentalObjectRestSpread: true,
    }
  },
  globals: {
    __DEV__: true
  },
  env: {
    browser: true,
    es6: true,
    jest: true,
  },
  extends: [
    "plugin:prettier/recommended",
  ],
  // add your custom rules here
  rules: {
    "no-console": 0,
  }
};
