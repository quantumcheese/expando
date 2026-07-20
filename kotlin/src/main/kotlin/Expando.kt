// Expando.kt – Kotlin implementation of the expando compression algorithm
// Provides overflow‑aware run‑length encoding compatible with the Rust/Node implementations.

package expando

import java.math.BigInteger
import java.nio.ByteBuffer
import java.nio.ByteOrder

/** Maximum 32‑bit unsigned integer value (2^32‑1) */
private val MAX_UINT32 = BigInteger("FFFFFFFF", 16) // 0xFFFFFFFF

/**
 * Encode a run length according to expando's overflow rules.
 * If the run exceeds MAX_UINT32, it emits MAX_UINT32 followed by a zero‑length run of the opposite bit,
 * and continues encoding the remaining count.
 *
 * Supports arbitrarily large runs using [BigInteger].
 */
fun encodeRunLength(runLength: BigInteger): List<BigInteger> {
    var remaining = runLength
    val encoded = mutableListOf<BigInteger>()
    val max = MAX_UINT32
    // Number of full MAX runs
    val fullRuns = remaining.divide(max)
    val remainder = remaining.remainder(max)
    for (i in BigInteger.ZERO until fullRuns) {
        encoded.add(max)   // run of current bit
        encoded.add(BigInteger.ZERO) // zero run for alternating bit
    }
    encoded.add(remainder) // final (<= MAX) run length
    return encoded
}

/** Convenience overload for Long values */
fun encodeRunLength(runLength: Long): List<Long> {
    return encodeRunLength(BigInteger.valueOf(runLength)).map { it.longValueExact() }
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
    val buffer = ByteBuffer.allocate(encoded.size * 4).order(ByteOrder.LITTLE_ENDIAN)
    for (value in encoded) {
        buffer.putInt(value.toInt()) // safe because value <= 0xFFFFFFFF
    }
    return buffer.array()
}

// Expose helpers for external use
object Expando {
    @JvmStatic fun encode(runLength: Long) = encodeRunLength(runLength)
    @JvmStatic fun encode(runLength: BigInteger) = encodeRunLength(runLength)
    @JvmStatic fun bitsToRuns(bits: String) = bitsToRuns(bits)
    @JvmStatic fun compress(bits: String) = compressBits(bits)
}
