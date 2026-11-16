class Swiftdraw < Formula
  desc "Convert SVG into PDF, PNG, JPEG or SF Symbol"
  homepage "https://github.com/swhitty/SwiftDraw"
  url "https://github.com/swhitty/SwiftDraw/archive/refs/tags/0.30.0.tar.gz"
  sha256 "a4684015c0dcb7cf220c7d8aa16cd86a4143c23521f51496e7eae7f3e04e3d16"
  license "Zlib"
  head "https://github.com/swhitty/SwiftDraw.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "87ada65c336d936ae3b017ad9ab1bd8752568b9599ad2a1c01cb1e5ce03ad38b"
  end

  uses_from_macos "swift" => :build
  uses_from_macos "libxml2"

  on_macos do
    depends_on xcode: ["16.0", :build]
  end

  deny_network_access!

  def fetch
    # SwiftPM tries to apply its own sandbox, which cannot nest inside the
    # build sandbox; Homebrew's sandbox still confines the whole process.
    system "swift", "package", "resolve", "--disable-sandbox"
  end

  def install
    args = std_swift_args
    if OS.linux?
      # Swift 6.4+ bypasses Homebrew's linker shim.
      args += ENV["HOMEBREW_LIBRARY_PATHS"].to_s.split(":").flat_map { ["-Xlinker", "-L#{it}"] } +
              ENV["HOMEBREW_RPATH_PATHS"].to_s.split(":").flat_map { ["-Xlinker", "-rpath", "-Xlinker", it] }
    end
    system "swift", "build", *args
    bin.install ".build/release/swiftdrawcli" => "swiftdraw"
  end

  test do
    (testpath/"fish.svg").write <<~SVG
      <?xml version="1.0" encoding="utf-8"?>
      <svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="160" height="160">
        <path d="m 80 20 a 50 50 0 1 0 50 50 h -50 z" fill="pink" stroke="black" stroke-width="2" transform="rotate(45, 80, 80)"/>
      </svg>
    SVG
    system bin/"swiftdraw", testpath/"fish.svg", "--format", "sfsymbol"
    assert_path_exists testpath/"fish-symbol.svg"
  end
end
