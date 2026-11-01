class Fnox < Formula
  desc "Fort Knox for your secrets - flexible secret management tool"
  homepage "https://fnox.jdx.dev/"
  url "https://github.com/jdx/fnox/archive/refs/tags/v1.46.0.tar.gz"
  sha256 "62b3e7a586cdf4ab4c4c4c3fb1f42ff8de8e4b36e24843720f65682b281677d6"
  license "MIT"
  head "https://github.com/jdx/fnox.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "a4b8928bffd537e639ff7234f55df6b344b266490dd6b3ba8dea05f6db961f63"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "age" => :test
  depends_on "openssl@4"
  depends_on "sqlcipher"
  depends_on "usage"

  on_linux do
    depends_on "aws-lc"
    depends_on "systemd" # libudev
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["AWS_LC_SYS_USE_SYSTEM"] = "1" if OS.linux?
    ENV["LIBSQLITE3_SYS_USE_PKG_CONFIG"] = "1"
    ENV["OPENSSL_NO_VENDOR"] = "1"
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4") if OS.mac?

    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"fnox", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fnox --version")

    test_key = shell_output("age-keygen")
    test_key_line = test_key.lines.grep(/^# public key:/).first.sub(/^# public key: /, "").strip
    secret_key_line = test_key.lines.grep(/^AGE-SECRET-KEY-/).first.strip

    (testpath/"fnox.toml").write <<~TOML
      [providers]
      age = { type = "age", recipients = ["#{test_key_line}"] }
    TOML

    ENV["FNOX_AGE_KEY"] = secret_key_line
    system bin/"fnox", "set", "TEST_SECRET", "test-secret-value", "--provider", "age"
    assert_match "TEST_SECRET", shell_output("#{bin}/fnox list")
    assert_match "test-secret-value", shell_output("#{bin}/fnox get TEST_SECRET")
  end
end
