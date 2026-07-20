// Node.js core encoder handling run-length encoding with overflow support
// Mirrors ../encoder.js for use within src folder
const MAX_UINT32 = 0xFFFFFFFF; // 2^32‑1, the maximum count representable in 32‑bit unsigned LE

/**
 * Encode a run length according to expando's overflow rules.
 * If the run exceeds MAX_UINT32, it emits MAX_UINT32 followed by a zero-length run of the opposite bit,
 * and continues encoding the remaining count.
 *
 * @param {number|bigint} runLength - Length of the run (number of consecutive bits). Can be a BigInt for very large values.
 * @returns {number[]} Array of 32‑bit unsigned integers (as JS Numbers) representing encoded counts.
 */
function encodeRunLength(runLength) {
  // Ensure we work with BigInt to avoid overflow of the JS number type for very large runs.
  let remaining = typeof runLength === 'bigint' ? runLength : BigInt(runLength);
  const MAX = BigInt(MAX_UINT32);
  const encoded = [];
  while (remaining > MAX) {
    // Emit a MAX run for the current bit
    encoded.push(Number(MAX));
    // Emit a zero run for the alternating bit
    encoded.push(0);
    remaining -= MAX;
  }
  // Emit the final (<= MAX) run length
  encoded.push(Number(remaining));
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
