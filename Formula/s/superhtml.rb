class Superhtml < Formula
  desc "HTML Language Server & Templating Language Library"
  homepage "https://github.com/kristoff-it/superhtml"
  url "https://github.com/kristoff-it/superhtml/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "a5092f06540749eb7e29025651e8f9c59819b6e8a574f7a13ebccb01243c2a32"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "27d21ba4f9bd89537975474edf7eda3c7d467dc19ca2b6a80839429f5a3f4b52"
  end

  depends_on "zig" => :build

  deny_network_access!

  def fetch
    system "zig", "build", "--fetch"
  end

  def install
    # upstream issue: https://github.com/kristoff-it/superhtml/issues/108
    inreplace "build.zig", '"unknown"', "\"#{version}\"" # patch fallback version

    system "zig", "build", *std_zig_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/superhtml version 2>&1")

    (testpath/"test.html").write <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
            <title>BrewTest</title>
        </head>
        <body>
            <h1>test</h1>
        </body>
      </html>
    HTML
    system bin/"superhtml", "fmt", "test.html"
  end
end
