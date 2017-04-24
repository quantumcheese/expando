import PackageDescription

let package = Package(
  name: "Inflato",
  dependencies: [
    .Package(url: "https://github.com/jatoben/CommandLine", Version("3.0.0-pre1"))
  ]
)
