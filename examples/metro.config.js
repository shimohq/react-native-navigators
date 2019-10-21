/**
 * Metro configuration for React Native
 * https://github.com/facebook/react-native
 *
 * @format
 */
var path = require("path");

module.exports = {
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: false,
      },
    })
  }
};
