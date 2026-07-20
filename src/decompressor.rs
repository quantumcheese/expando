use std::io::{self, Read, Write};

/// Decompresses the input stream using the bit-run compression algorithm.
/// Reads alternating u32 counts (little-endian) and reconstructs the bitstream,
/// writing the resulting bytes to the output stream.
/// 
/// Returns `Ok((compressed_bytes, decompressed_bytes))` upon success.
pub fn decompress<R: Read, W: Write>(
    reader: R,
    writer: W,
) -> io::Result<(u64, u64)> {
    let mut reader = io::BufReader::new(reader);
    let mut writer = io::BufWriter::new(writer);

    let mut compressed_bytes: u64 = 0;
    let mut decompressed_bytes: u64 = 0;

    let mut current_run: u8 = 0; // Always start by decoding 0s
    let mut byte_buffer: u8 = 0;
    let mut bit_count: u32 = 0;

    let mut u32_buf = [0u8; 4];

    loop {
        let mut bytes_read = 0;
        while bytes_read < 4 {
            match reader.read(&mut u32_buf[bytes_read..]) {
                Ok(0) => {
                    if bytes_read == 0 {
                        // EOF reached on a clean u32 boundary
                        break;
                    } else {
                        return Err(io::Error::new(
                            io::ErrorKind::InvalidData,
                            "Compressed file is truncated or corrupted (partial integer at end)",
                        ));
                    }
                }
                Ok(n) => {
                    bytes_read += n;
                }
                Err(ref e) if e.kind() == io::ErrorKind::Interrupted => {}
                Err(e) => return Err(e),
            }
        }

        if bytes_read == 0 {
            break;
        }

        compressed_bytes += 4;
        let count = u32::from_le_bytes(u32_buf);

        // Emit 'count' bits of value 'current_run'
        for _ in 0..count {
            byte_buffer |= current_run << (7 - bit_count);
            bit_count += 1;
            if bit_count == 8 {
                writer.write_all(&[byte_buffer])?;
                decompressed_bytes += 1;
                byte_buffer = 0;
                bit_count = 0;
            }
        }

        // Toggle run
        current_run = 1 - current_run;
    }

    // Flush any pending data in the output buffer
    writer.flush()?;

    // Check if the decoded bits form a whole number of bytes
    if bit_count > 0 {
        return Err(io::Error::new(
            io::ErrorKind::InvalidData,
            "Compressed file is corrupted (decoded bitstream is not byte-aligned)",
        ));
    }

    Ok((compressed_bytes, decompressed_bytes))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_decompress_empty() {
        let input: &[u8] = &[];
        let mut output = Vec::new();
        let (comp, decomp) = decompress(input, &mut output).unwrap();
        assert_eq!(comp, 0);
        assert_eq!(decomp, 0);
        assert!(output.is_empty());
    }

    #[test]
    fn test_decompress_basic_zeros() {
        let mut input = Vec::new();
        input.extend_from_slice(&8u32.to_le_bytes()); // 8 zeros
        let mut output = Vec::new();
        let (comp, decomp) = decompress(&input[..], &mut output).unwrap();
        assert_eq!(comp, 4);
        assert_eq!(decomp, 1);
        assert_eq!(output, vec![0x00]);
    }

    #[test]
    fn test_decompress_starts_with_one() {
        let mut input = Vec::new();
        input.extend_from_slice(&0u32.to_le_bytes()); // zero 0s
        input.extend_from_slice(&1u32.to_le_bytes()); // one 1
        input.extend_from_slice(&7u32.to_le_bytes()); // seven 0s
        let mut output = Vec::new();
        let (comp, decomp) = decompress(&input[..], &mut output).unwrap();
        assert_eq!(comp, 12);
        assert_eq!(decomp, 1);
        assert_eq!(output, vec![0x80]);
    }

    #[test]
    fn test_decompress_truncated() {
        // Only 2 bytes (truncated u32)
        let input = [0x01, 0x02];
        let mut output = Vec::new();
        let res = decompress(&input[..], &mut output);
        assert!(res.is_err());
        assert_eq!(res.unwrap_err().kind(), io::ErrorKind::InvalidData);
    }

    #[test]
    fn test_decompress_not_byte_aligned() {
        let mut input = Vec::new();
        input.extend_from_slice(&5u32.to_le_bytes()); // 5 zeros (not a multiple of 8 bits)
        let mut output = Vec::new();
        let res = decompress(&input[..], &mut output);
        assert!(res.is_err());
        assert_eq!(res.unwrap_err().kind(), io::ErrorKind::InvalidData);
    }

    struct MockCountWriter {
        bytes_written: u64,
    }

    impl std::io::Write for MockCountWriter {
        fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
            self.bytes_written += buf.len() as u64;
            Ok(buf.len())
        }
        fn flush(&mut self) -> std::io::Result<()> {
            Ok(())
        }
    }

    #[test]
    fn test_decompress_large_overflow() {
        let mut input = Vec::new();
        input.extend_from_slice(&u32::MAX.to_le_bytes());
        input.extend_from_slice(&0u32.to_le_bytes());
        input.extend_from_slice(&9u32.to_le_bytes()); // total: u32::MAX + 9 zeros -> 4294967304 bits = 536870913 bytes
        
        let mut writer = MockCountWriter { bytes_written: 0 };
        let (comp, decomp) = decompress(&input[..], &mut writer).unwrap();
        assert_eq!(comp, 12);
        assert_eq!(decomp, 536870913);
        assert_eq!(writer.bytes_written, 536870913);
    }
}

