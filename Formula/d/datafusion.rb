class Datafusion < Formula
  desc "Apache Arrow DataFusion and Ballista query engines"
  homepage "https://arrow.apache.org/datafusion"
  url "https://www.apache.org/dyn/closer.lua?path=datafusion/datafusion-55.1.0/apache-datafusion-55.1.0.tar.gz"
  mirror "https://archive.apache.org/dist/datafusion/datafusion-55.1.0/apache-datafusion-55.1.0.tar.gz"
  sha256 "9399749c87b48d91de8352ad4f30ad418c4d4fc1a55aed2dee3c0aaecb4c6a04"
  license "Apache-2.0"
  head "https://github.com/apache/datafusion.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "0b3f70177032bb970ea6ca8e0a7cd83d0857e8b318a2ac53d9d38cf48c9437d8"
  end

  depends_on "rust" => :build

  def install
    # Avoid OOM on GitHub runners
    inreplace "Cargo.toml", /^lto = true$/, 'lto = "thin"' if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]

    system "cargo", "install", *std_cargo_args(path: "datafusion-cli")
  end

  test do
    (testpath/"datafusion_test.sql").write <<~SQL
      select 1+2 as n;
    SQL
    assert_equal "[{\"n\":3}]", shell_output("#{bin}/datafusion-cli -q --format json -f datafusion_test.sql").strip
  end
end
