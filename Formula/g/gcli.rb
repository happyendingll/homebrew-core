class Gcli < Formula
  desc "Portable Git(hub|lab|tea)/Forgejo/Bugzilla CLI tool"
  homepage "https://herrhotzenplotz.de/gcli/"
  url "https://github.com/herrhotzenplotz/gcli/archive/refs/tags/v2.13.0.tar.gz"
  sha256 "3dd25f636e439f7af6187248e46f2b4078dffdca4fe2d506d0edb275515d62b4"
  license "BSD-2-Clause"
  revision 1
  head "https://github.com/herrhotzenplotz/gcli.git", branch: "trunk"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "4d753fa1ee07e60152e49441c7bc72418031302a47b25111dfe40c77592ec850"
  end

  depends_on "pkgconf" => :build
  depends_on "readline" => :build
  depends_on "lowdown"
  depends_on "openssl@3"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build
  uses_from_macos "curl"
  uses_from_macos "libedit"

  def install
    # Do not use `*std_configure_args`, `./configure` script throws errors if unknown flag is passed
    system "./configure", "--prefix=#{prefix}", "--release"
    system "make", "install"
  end

  test do
    assert_match "gcli: error: no account specified or no default account configured",
      shell_output("#{bin}/gcli -t github repos 2>&1", 1)
    assert_match(/FORK\s+VISBLTY\s+DATE\s+FULLNAME/,
      shell_output("#{bin}/gcli -t github repos -o linus"))
  end
end
