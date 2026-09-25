class IntelliShell < Formula
  desc "Like IntelliSense, but for shells"
  homepage "https://lasantosr.github.io/intelli-shell/"
  license "Apache-2.0"
  head "https://github.com/lasantosr/intelli-shell.git", branch: "main"

  stable do
    url "https://github.com/lasantosr/intelli-shell/archive/refs/tags/v3.4.5.tar.gz"
    sha256 "3bb19e59f65e5076c549379cdd8bbe37ab38ddb45187f2333d4356f49e5b1f41"

    # Backport support for OpenSSL 4
    patch do
      url "https://github.com/lasantosr/intelli-shell/commit/fecf5c2ba5ecf648e8e582361f4568f937e014ff.patch?full_index=1"
      sha256 "760c4982138e87ef95a903e87ca60de6f0bf58843d1fa7446f0971eb6dc3f8f9"
      type :backport
      resolves "https://github.com/lasantosr/intelli-shell/issues/63"
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "401d2c4503be7499b075351be81a6ef273aa87656197f71027021751245ef516"
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
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/intelli-shell --version")

    system bin/"intelli-shell", "config", "--path"

    output = shell_output("#{bin}/intelli-shell export 2>&1", 1)
    assert_match "[Error] No commands or completions to export", output
  end
end
