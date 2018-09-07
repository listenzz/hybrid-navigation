function fontUri(fontFamily, name, size = 24, color = '#FFFFFF') {
  let glyphMap;
  if (fontFamily === 'FontAwesome') {
    glyphMap = require('react-native-vector-icons/glyphmaps/FontAwesome.json');
  } else {
    console.error(`还没处理 ${fontFamily} 这种字体`);
  }

  if (!glyphMap) {
    glyphMap = require('react-native-vector-icons/glyphmaps/FontAwesome.json');
  }

  let glyph = glyphMap[name] || '?';
  if (typeof glyph === 'number') {
    glyph = String.fromCharCode(glyph);
  }
  let uri = `font://${fontFamily}/${glyph}/${size}/${color}`;
  return uri;
}

export default fontUri;
