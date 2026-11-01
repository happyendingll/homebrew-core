class Gcli < Formula
  desc "Portable Git(hub|lab|tea)/Forgejo/Bugzilla CLI tool"
  homepage "https://herrhotzenplotz.de/gcli/"
  url "https://github.com/herrhotzenplotz/gcli/archive/refs/tags/v2.14.0.tar.gz"
  sha256 "ec9150b79af2a4a8333152a93085efa95bb1419a9e0c48b63f916974fc752bfd"
  license "BSD-2-Clause"
  head "https://github.com/herrhotzenplotz/gcli.git", branch: "trunk"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "673e2672e99d5b76ae3a5eb87603565de1a3c60dc1efbc2c91d0b165542246c0"
  end

  depends_on "pkgconf" => :build
  depends_on "readline" => :build
  depends_on "lowdown"
  depends_on "openssl@4"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build
  uses_from_macos "curl"
  uses_from_macos "libedit"

  allow_network_access! :test

  def install
    # Do not use `*std_configure_args`, `./configure` script throws errors if unknown flag is passed
    system "./configure", "--prefix=#{prefix}", "--release"
    system "make", "install"
  end

  test do
    assert_match "gcli: error: no account specified or no default account configured",
      shell_output("#{bin}/gcli -t gitlab repos 2>&1", 1)
    assert_match(/FORK\s+VISBLTY\s+DATE\s+FULLNAME/,
      shell_output("#{bin}/gcli -t gitlab repos -o herrhotzenplotz"))
  end
end
