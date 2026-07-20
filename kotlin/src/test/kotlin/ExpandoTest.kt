package expando

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import java.math.BigInteger

class ExpandoTest {
    @Test
    fun `encodeRunLength overflow test`() {
        // Run length of 2^36 (68719476736) which exceeds MAX_UINT32
        val runLength = BigInteger("10000000000", 16) // 2^36
        val encoded = Expando.encode(runLength)
        // Expected full runs: runLength / MAX_UINT32 = 16, remainder = 16
        val expectedFullRuns = runLength.divide(BigInteger("FFFFFFFF", 16))
        val expectedRemainder = runLength.remainder(BigInteger("FFFFFFFF", 16))
        // Verify number of encoded elements
        // Each full run contributes two values (MAX and 0), plus final remainder
        val expectedSize = expectedFullRuns.toInt() * 2 + 1
        assertEquals(expectedSize, encoded.size)
        // Verify the pattern of values
        for (i in 0 until expectedFullRuns.toInt()) {
            assertEquals(BigInteger("FFFFFFFF", 16), encoded[i * 2])
            assertEquals(BigInteger.ZERO, encoded[i * 2 + 1])
        }
        assertEquals(expectedRemainder, encoded.last())
    }
}
