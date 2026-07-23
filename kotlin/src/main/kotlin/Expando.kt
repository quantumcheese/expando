package expando

/** Maximum 32‑bit unsigned integer value (2^32‑1) */
private const val MAX_UINT32: Long = 0xFFFFFFFFL

/**
 * Encode a run length according to expando's overflow rules.
 * If the run exceeds MAX_UINT32, it emits MAX_UINT32 followed by a zero‑length run of the opposite bit,
 * and continues encoding the remaining count.
 */
fun encodeRunLength(runLength: Long): List<Long> {
    var remaining = runLength
    val encoded = mutableListOf<Long>()
    val max = MAX_UINT32
    // Number of full MAX runs
    val fullRuns = remaining / max
    val remainder = remaining % max
    for (i in 0L until fullRuns) {
        encoded.add(max)   // run of current bit
        encoded.add(0L)    // zero run for alternating bit
    }
    encoded.add(remainder) // final (<= MAX) run length
    return encoded
}

/** Convert a binary string (e.g., "010011") into a list of run lengths.
 * The first run always corresponds to zeros as per the algorithm.
 */
fun bitsToRuns(bits: String): List<Long> {
    if (bits.isEmpty()) return emptyList()
    val runs = mutableListOf<Long>()
    var currentBit = '0'
    var count = 0L
    for (ch in bits) {
        if (ch == currentBit) {
            count++
        } else {
            runs.add(count) // may be zero
            currentBit = ch
            count = 1L
        }
    }
    runs.add(count)
    return runs
}

/**
 * Encode a binary string using expando's overflow‑aware encoding.
 * Returns a ByteArray containing the little‑endian 32‑bit unsigned integers.
 */
fun compressBits(bits: String): ByteArray {
    val runs = bitsToRuns(bits)
    val encoded = mutableListOf<Long>()
    for (run in runs) {
        encoded.addAll(encodeRunLength(run))
    }
    // Convert to ByteArray (little‑endian UInt32)
    val result = ByteArray(encoded.size * 4)
    for (i in encoded.indices) {
        val value = encoded[i]
        val offset = i * 4
        result[offset] = (value and 0xFF).toByte()
        result[offset + 1] = ((value shr 8) and 0xFF).toByte()
        result[offset + 2] = ((value shr 16) and 0xFF).toByte()
        result[offset + 3] = ((value shr 24) and 0xFF).toByte()
    }
    return result
}

// Expose helpers for external use
object Expando {
    fun encode(runLength: Long): List<Long> = encodeRunLength(runLength)
    fun bitsToRuns(bits: String): List<Long> = expando.bitsToRuns(bits)
    fun compress(bits: String): ByteArray = compressBits(bits)
}
