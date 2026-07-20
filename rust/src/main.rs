mod compressor;
mod decompressor;

fn print_usage() {
    eprintln!(
        "expando - Bit-Run Length Encoding Compression Utility

Usage:
  expando compress <input> <output>
  expando decompress <input> <output>

Arguments:
  <input>      Input file path, or '-' for standard input (stdin)
  <output>     Output file path, or '-' for standard output (stdout)

Options:
  -h, --help   Print this help message
"
    );
}

fn main() {
    let args: Vec<String> = std::env::args().collect();

    // Check for help flags
    if args.len() == 2 && (args[1] == "-h" || args[1] == "--help") {
        print_usage();
        return;
    }

    if args.len() != 4 {
        print_usage();
        std::process::exit(1);
    }

    let subcommand = &args[1];
    let input_path = &args[2];
    let output_path = &args[3];

    if subcommand != "compress" && subcommand != "decompress" {
        eprintln!("Error: Unknown subcommand '{}'\n", subcommand);
        print_usage();
        std::process::exit(1);
    }

    // Resolve input stream
    let input_stream: Box<dyn std::io::Read> = if input_path == "-" {
        Box::new(std::io::stdin())
    } else {
        match std::fs::File::open(input_path) {
            Ok(file) => Box::new(file),
            Err(e) => {
                eprintln!("Error: Cannot open input file '{}': {}", input_path, e);
                std::process::exit(1);
            }
        }
    };

    // Resolve output stream
    let output_stream: Box<dyn std::io::Write> = if output_path == "-" {
        Box::new(std::io::stdout())
    } else {
        match std::fs::File::create(output_path) {
            Ok(file) => Box::new(file),
            Err(e) => {
                eprintln!("Error: Cannot create output file '{}': {}", output_path, e);
                std::process::exit(1);
            }
        }
    };

    let start = std::time::Instant::now();

    match subcommand.as_str() {
        "compress" => {
            match compressor::compress(input_stream, output_stream) {
                Ok((orig, comp)) => {
                    let duration = start.elapsed();
                    eprintln!("Compression completed successfully!");
                    eprintln!("Original size:   {} bytes", orig);
                    eprintln!("Compressed size: {} bytes", comp);
                    if orig > 0 {
                        let ratio = (comp as f64) / (orig as f64) * 100.0;
                        let factor = if comp > 0 {
                            format!("{:.2}x", (orig as f64) / (comp as f64))
                        } else {
                            "N/A".to_string()
                        };
                        let speed = (orig as f64) / (1024.0 * 1024.0) / duration.as_secs_f64();
                        eprintln!("Ratio:           {:.2}% (compressed is {} smaller)", ratio, factor);
                        eprintln!("Throughput:      {:.2} MB/s", speed);
                    } else {
                        eprintln!("Empty file compressed successfully.");
                    }
                }
                Err(e) => {
                    eprintln!("Error during compression: {}", e);
                    std::process::exit(1);
                }
            }
        }
        "decompress" => {
            match decompressor::decompress(input_stream, output_stream) {
                Ok((comp, decomp)) => {
                    let duration = start.elapsed();
                    eprintln!("Decompression completed successfully!");
                    eprintln!("Compressed size:   {} bytes", comp);
                    eprintln!("Decompressed size: {} bytes", decomp);
                    if duration.as_secs_f64() > 0.0 {
                        let speed = (decomp as f64) / (1024.0 * 1024.0) / duration.as_secs_f64();
                        eprintln!("Throughput:        {:.2} MB/s", speed);
                    }
                }
                Err(e) => {
                    eprintln!("Error during decompression: {}", e);
                    std::process::exit(1);
                }
            }
        }
        _ => unreachable!(),
    }
}
