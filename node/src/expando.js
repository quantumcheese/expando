// Node.js core expando implementation
// Provides a simple API to compress a binary string using expando's run-length encoding.
// This module is intentionally lightweight and does not perform file I/O; it operates on strings/arrays.

const { encodeRunLength } = require('./encoder');

/**
 * Convert a binary string (e.g., "010011") into an array of run lengths.
 * The first run is always for zeros as per the algorithm.
 * @param {string} bits - String of '0' and '1' characters.
 * @returns {number[]} Array of run lengths.
 */
function bitsToRuns(bits) {
  if (!bits) return [];
  const runs = [];
  let currentBit = '0'; // algorithm always starts with zeros run
  let count = 0;
  for (const ch of bits) {
    if (ch === currentBit) {
      count++;
    } else {
      // flush current run (may be zero length)
      runs.push(count);
      // switch bit and start new count
      currentBit = ch;
      count = 1;
    }
  }
  // push final run
  runs.push(count);
  return runs;
}

/**
 * Encode a binary string using expando's overflow‑aware run‑length encoding.
 * Returns a Buffer containing the little‑endian 32‑bit integers.
 * @param {string} bits - Binary input as a string of 0/1.
 * @returns {Buffer}
 */
function compressBits(bits) {
  const runs = bitsToRuns(bits);
  const encoded = [];
  for (const run of runs) {
    // encode each run length; encodeRunLength returns an array handling overflow
    encoded.push(...encodeRunLength(run));
  }
  const { uint32ArrayToBuffer } = require('./encoder');
  return uint32ArrayToBuffer(encoded);
}

module.exports = { bitsToRuns, compressBits };
