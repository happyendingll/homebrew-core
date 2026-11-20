class Mdcat < Formula
  desc "Show markdown documents on text terminals"
  homepage "https://github.com/BIRSAx2/mdcat"
  url "https://github.com/BIRSAx2/mdcat/archive/refs/tags/mdcat-2.20.2.tar.gz"
  sha256 "511a20572635faa0d6b0fd1080d7336a5b38738ad6d189abe9c7a71facd3c5d7"
  license "MPL-2.0"
  head "https://github.com/BIRSAx2/mdcat.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "2b5d51907450bab0661becbc4ec6ea72fd8d95cd5e4df575805d108ec2849198"
  end

  depends_on "asciidoctor" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "curl"

  on_linux do
    depends_on "openssl@4"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    # https://github.com/BIRSAx2/mdcat?tab=readme-ov-file#packaging
    generate_completions_from_executable(bin/"mdcat", shell_parameter_format: "--completions=")
    system "asciidoctor", "-b", "manpage", "-a", "reproducible", "-o", "mdcat.1", "mdcat.1.adoc"
    man1.install Utils::Gzip.compress("mdcat.1")
  end

  test do
    (testpath/"test.md").write <<~MARKDOWN
      _lorem_ **ipsum** dolor **sit** _amet_
    MARKDOWN
    output = shell_output("#{bin}/mdcat --no-colour test.md")
    assert_match "lorem ipsum dolor sit amet", output
  end
end
