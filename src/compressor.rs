use std::io::{self, Read, Write};

/// Compresses the input stream using the bit-run compression algorithm.
/// Reads bits MSB-to-LSB, and outputs alternating run counts as raw little-endian u32s.
/// 
/// Returns `Ok((original_bytes, compressed_bytes))` upon success.
pub fn compress<R: Read, W: Write>(
    reader: R,
    writer: W,
) -> io::Result<(u64, u64)> {
    let mut reader = io::BufReader::new(reader);
    let mut writer = io::BufWriter::new(writer);

    let mut original_bytes: u64 = 0;
    let mut compressed_bytes: u64 = 0;

    let mut current_run: u8 = 0; // Always start by counting 0s
    let mut count: u32 = 0;
    let mut has_processed_any = false;

    let mut buffer = [0u8; 8192];

    loop {
        let n = reader.read(&mut buffer)?;
        if n == 0 {
            break;
        }
        has_processed_any = true;
        original_bytes += n as u64;

        for &byte in &buffer[..n] {
            // Iterate bits from MSB (7) to LSB (0)
            for bit_idx in (0..8).rev() {
                let bit = (byte >> bit_idx) & 1;

                if bit == current_run {
                    if count == u32::MAX {
                        // Overflow handling: write MAX_INT, then 0, then reset count to 1 for the same bit run type
                        writer.write_all(&u32::MAX.to_le_bytes())?;
                        writer.write_all(&0u32.to_le_bytes())?;
                        compressed_bytes += 8;
                        count = 1;
                    } else {
                        count += 1;
                    }
                } else {
                    // Transition to the other bit: write current count and switch
                    writer.write_all(&count.to_le_bytes())?;
                    compressed_bytes += 4;
                    current_run = bit;
                    count = 1;
                }
            }
        }
    }

    // Write final remaining run if any bits were processed
    if has_processed_any || count > 0 {
        writer.write_all(&count.to_le_bytes())?;
        compressed_bytes += 4;
    }

    writer.flush()?;

    Ok((original_bytes, compressed_bytes))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_compress_empty() {
        let input: &[u8] = &[];
        let mut output = Vec::new();
        let (orig, comp) = compress(input, &mut output).unwrap();
        assert_eq!(orig, 0);
        assert_eq!(comp, 0);
        assert!(output.is_empty());
    }

    #[test]
    fn test_compress_basic_zeros() {
        let input = [0x00]; // 8 zeros
        let mut output = Vec::new();
        let (orig, comp) = compress(&input[..], &mut output).unwrap();
        assert_eq!(orig, 1);
        assert_eq!(comp, 4);
        assert_eq!(output, 8u32.to_le_bytes());
    }

    #[test]
    fn test_compress_starts_with_one() {
        let input = [0x80]; // 1, 0, 0, 0, 0, 0, 0, 0
        let mut output = Vec::new();
        let (orig, comp) = compress(&input[..], &mut output).unwrap();
        assert_eq!(orig, 1);
        assert_eq!(comp, 12);
        
        let mut expected = Vec::new();
        expected.extend_from_slice(&0u32.to_le_bytes()); // zero 0s
        expected.extend_from_slice(&1u32.to_le_bytes()); // one 1
        expected.extend_from_slice(&7u32.to_le_bytes()); // seven 0s
        assert_eq!(output, expected);
    }

    #[test]
    fn test_compress_alternating() {
        let input = [0x55]; // 01010101
        let mut output = Vec::new();
        let (orig, comp) = compress(&input[..], &mut output).unwrap();
        assert_eq!(orig, 1);
        assert_eq!(comp, 32);
        
        let mut expected = Vec::new();
        for _ in 0..8 {
            expected.extend_from_slice(&1u32.to_le_bytes());
        }
        assert_eq!(output, expected);
    }

    struct MockZeroReader {
        total_bytes: u64,
        read_bytes: u64,
    }

    impl std::io::Read for MockZeroReader {
        fn read(&mut self, buf: &mut [u8]) -> std::io::Result<usize> {
            let remaining = self.total_bytes - self.read_bytes;
            if remaining == 0 {
                return Ok(0);
            }
            let to_read = std::cmp::min(buf.len() as u64, remaining) as usize;
            buf[..to_read].fill(0);
            self.read_bytes += to_read as u64;
            Ok(to_read)
        }
    }

    #[test]
    fn test_compress_large_overflow() {
        // u32::MAX + 9 zeros -> 4294967304 bits = 536870913 bytes
        let total_bytes = 536870913;
        let reader = MockZeroReader {
            total_bytes,
            read_bytes: 0,
        };
        let mut output = Vec::new();
        let (orig, comp) = compress(reader, &mut output).unwrap();
        assert_eq!(orig, total_bytes);
        assert_eq!(comp, 12); // should write: u32::MAX, 0, 9

        let mut expected = Vec::new();
        expected.extend_from_slice(&u32::MAX.to_le_bytes());
        expected.extend_from_slice(&0u32.to_le_bytes());
        expected.extend_from_slice(&9u32.to_le_bytes());
        assert_eq!(output, expected);
    }
}

