class CrystalIcr < Formula
  desc "Interactive console for Crystal programming language"
  homepage "https://github.com/crystal-community/icr"
  url "https://github.com/crystal-community/icr/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "2530293e94b60d69919a79b49e83270f1462058499ad37a762233df8d6e5992c"
  license "MIT"
  revision 4

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 sequoia: "0e9ee4f4d9f98499397afc124adb3550ed82d914d4b809ff80e252576e09f1e7"
  end

  depends_on "bdw-gc"
  depends_on "crystal"
  depends_on "libyaml"
  depends_on "openssl@4"
  depends_on "pcre2"
  depends_on "readline"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # Fix build with Crystal 1.21
  patch do
    url "https://github.com/crystal-community/icr/commit/bebf21ccea7c372b86d233552b05b824b21e97f7.patch?full_index=1"
    sha256 "50b632eb3115eaa10b92b99df1cac9cdfbf4c2523204bd22b6a8c590f8204427"
    type :unofficial
    resolves "https://github.com/crystal-community/icr/pull/136"
  end

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_match "icr version #{version}", shell_output("#{bin}/icr -v")
  end
end
