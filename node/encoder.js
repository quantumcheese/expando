// expando Node.js implementation – core encoder handling run-length encoding with overflow support
// This module provides utilities to encode runs of bits according to the expando algorithm.
// It does NOT perform full file I/O; higher-level APIs can wrap these functions.

const MAX_UINT32 = 0xFFFFFFFF; // 2^32‑1, the maximum count representable in 32‑bit unsigned LE

/**
 * Encode a run length according to expando's overflow rules.
 * If the run exceeds MAX_UINT32, it emits MAX_UINT32 followed by a zero-length run of the opposite bit,
 * and continues encoding the remaining count.
 *
 * @param {number|bigint} runLength - Length of the run (number of consecutive bits). Can be a BigInt for very large values.
 * @returns {number[]} Array of 32‑bit unsigned integers (as JS Numbers) representing encoded counts.
 */
// Efficient overflow-aware encoding using division
function encodeRunLength(runLength) {
  // Work with BigInt for arbitrary size runs
  let remaining = typeof runLength === 'bigint' ? runLength : BigInt(runLength);
  const MAX = BigInt(MAX_UINT32);
  const encoded = [];
  // Determine how many full MAX runs we need
  const fullRuns = remaining / MAX;
  const remainder = remaining % MAX;
  // For each full MAX run, emit MAX then a zero run for the alternating bit
  for (let i = 0n; i < fullRuns; i++) {
    encoded.push(Number(MAX));
    encoded.push(0);
  }
  // Emit the final remainder (could be zero)
  encoded.push(Number(remainder));
  return encoded;
}

/**
 * Convert an array of 32‑bit unsigned integers to a Buffer in little‑endian order.
 * Useful for writing the binary output file.
 *
 * @param {number[]} uint32Array
 * @returns {Buffer}
 */
function uint32ArrayToBuffer(uint32Array) {
  const buf = Buffer.alloc(uint32Array.length * 4);
  uint32Array.forEach((v, i) => buf.writeUInt32LE(v, i * 4));
  return buf;
}

module.exports = {
  MAX_UINT32,
  encodeRunLength,
  uint32ArrayToBuffer,
};
