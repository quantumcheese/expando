# expando

`expando` is a command-line compression utility written in Rust. It implements a custom **Alternating Bit-Run Length Encoding (RLE)** algorithm that operates on the individual bits of a file.

## Features

- **Bit-Level RLE**: Compresses binary streams by counting runs of alternating bits (zeros and ones).
- **Infinite Run Support**: Gracefully handles runs larger than the maximum integer size (`u32::MAX`) with minimal overhead.
- **Unix Philosophy Friendly**: Supports standard input/output streams (`-`), allowing easy piping and integration with standard tools like `tar` for multi-file archiving.
- **Performance Statistics**: Displays original size, compressed size, compression ratios, and speed/throughput upon completion.

---

## The Compression Algorithm

### 1. Alternation sequence
The algorithm reads the input stream as binary bits. Counts of runs always alternate between `0`s and `1`s.
- The compressed output **always begins by counting `0`s**.
- If the input starts with a `1`, a `0` is written as the first run count to signify a run of zero `0`s.

### 2. Binary Representation
Each run length count is written as a **32-bit unsigned integer (`u32`) in Little-Endian format**.
- `MAX_INT` = $2^{32} - 1 = 4,294,967,295$.

### 3. Overflow Handling
If a consecutive run of identical bits exceeds `MAX_INT`:
- It writes `MAX_INT` (the maximum count for the current bit type).
- It writes `0` (the count for the alternating bit type, indicating a zero-length run).
- It resumes counting the remaining identical bits.
- *Optimization*: If a run is exactly `MAX_INT` and is immediately followed by the opposite bit type (or EOF), the utility transitions directly to the next bit type without writing a dummy `0`.

### 4. Bit Ordering
Bits within each byte of the source file are read from **Most Significant Bit (MSB, bit 7)** to **Least Significant Bit (LSB, bit 0)**.

---

## Installation & Requirements

To build and run `expando`, you must have Rust and Cargo installed.

```bash
# Clone the repository and build the release binary
cargo build --release

# The compiled binary will be available at target/release/expando
```

---

## Usage

```
expando - Bit-Run Length Encoding Compression Utility

Usage:
  expando compress <input> <output>
  expando decompress <input> <output>

Arguments:
  <input>      Input file path, or '-' for standard input (stdin)
  <output>     Output file path, or '-' for standard output (stdout)

Options:
  -h, --help   Print this help message
```

### Examples

#### 1. Compress and Decompress a Single File
```bash
# Compress a file
./target/release/expando compress document.pdf document.exp

# Decompress the file
./target/release/expando decompress document.exp document_restored.pdf
```

#### 2. Pipe using Stdin and Stdout
```bash
# Compress data from another command
cat file.txt | ./target/release/expando compress - file.exp
```

#### 3. Archive and Compress Multiple Files (Unix Philosophy)
Since `expando` operates on a single stream, you can combine it with `tar` to compress directories:
```bash
# Archive and compress a folder
tar -cf - my_folder/ | ./target/release/expando compress - archive.tar.exp

# Decompress and extract the folder
./target/release/expando decompress archive.tar.exp - | tar -xf - -C destination_dir/
```

---

## Testing

Run the unit and integration tests using Cargo:

```bash
cargo test
```

The test suite includes boundary condition testing, empty stream handling, alignment validation, and simulated run overflow (asserting correct encoding on mock bitstreams of over 4 billion consecutive bits without allocating massive memory).

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

