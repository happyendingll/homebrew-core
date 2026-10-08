class Datafusion < Formula
  desc "Apache Arrow DataFusion and Ballista query engines"
  homepage "https://arrow.apache.org/datafusion"
  url "https://www.apache.org/dyn/closer.lua?path=datafusion/datafusion-55.2.0/apache-datafusion-55.2.0.tar.gz"
  mirror "https://archive.apache.org/dist/datafusion/datafusion-55.2.0/apache-datafusion-55.2.0.tar.gz"
  sha256 "54b40ccacf006ad5967b7d398b5f7e111a682c4d6f9a519c929ab0f02da0f176"
  license "Apache-2.0"
  head "https://github.com/apache/datafusion.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "148d48ca6c433f02c967ac9249c83842043ce9990ad4e5fb16873c47eb990fb6"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

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
