package expando

import kotlin.test.Test
import kotlin.test.assertEquals

class ExpandoTest {
    @Test
    fun testBitsToRuns() {
        val runs = Expando.bitsToRuns("010011")
        assertEquals(listOf(1L, 1L, 2L, 2L), runs)
    }

    @Test
    fun testEncode() {
        val encoded = Expando.encode(5L)
        assertEquals(listOf(5L), encoded)
    }

    @Test
    fun testCompress() {
        val bytes = Expando.compress("01")
        assertEquals(8, bytes.size)
    }
}
