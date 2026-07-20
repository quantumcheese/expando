// tests/compress.test.js
const assert = require('assert');
const { encodeRunLength, MAX_UINT32 } = require('../encoder');

describe('encodeRunLength', () => {
  it('encodes a small run without overflow', () => {
    const result = encodeRunLength(123);
    assert.deepStrictEqual(result, [123]);
  });

  it('encodes overflow for MAX_UINT32+1', () => {
    const bigRun = MAX_UINT32 + 1;
    const result = encodeRunLength(bigRun);
    const expected = [MAX_UINT32, 0, 1];
    assert.deepStrictEqual(result, expected);
  });
});
