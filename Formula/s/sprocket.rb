class Sprocket < Formula
  desc "Bioinformatics workflow engine built on the Workflow Description Language (WDL)"
  homepage "https://sprocket.bio"
  url "https://github.com/stjude-rust-labs/sprocket/archive/refs/tags/v0.34.1.tar.gz"
  sha256 "e5d13afcf1beb48cc8c5947ca35b02849c3cdd940490f3f936887fb54c026056"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/stjude-rust-labs/sprocket.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "7fee60fb5d4d0ef7cf91ad890cb954f9690b30122be9650060bdeab254e82bb1"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"sprocket", "completions", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sprocket --version")

    (testpath/"hello.wdl").write <<~WDL
      version 1.2

      task say_hello {
        input {
          String greeting
          String name
        }

        command <<<
          echo "~{greeting}, ~{name}!"
        >>>

        output {
          String message = read_string(stdout())
        }

        runtime {
          container: "ubuntu:latest"
        }
      }
    WDL

    output = shell_output("#{bin}/sprocket inputs --target say_hello #{testpath}/hello.wdl")
    assert_match <<~JSON.strip, output
      {
        "say_hello.greeting": "String <REQUIRED>",
        "say_hello.name": "String <REQUIRED>"
      }
    JSON
  end
end
