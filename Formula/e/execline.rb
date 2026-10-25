class Execline < Formula
  desc "Interpreter-less scripting language"
  homepage "https://skarnet.org/software/execline/"
  url "https://skarnet.org/software/execline/execline-2.10.0.0.tar.gz"
  sha256 "561be2ce578604644e2263a889bbdf4736e7980401ee88556a7f9017c166dbab"
  license "ISC"
  head "git://git.skarnet.org/execline", branch: "main"

  livecheck do
    url :homepage
    regex(/href=.*?execline[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "8f2c4e635c0558467bee5c22293e34930b26b5c163a0c56a155066a0628feb27"
  end

  depends_on "pkgconf" => :build
  depends_on "skalibs"

  deny_network_access!

  def install
    args = %W[
      --disable-silent-rules
      --enable-shared
      --enable-pkgconfig
      --with-pkgconfig=#{formula_opt_bin("pkgconf")}/pkg-config
      --with-sysdeps=#{formula_opt_lib("skalibs")}/skalibs/sysdeps
    ]
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.eb").write <<~EOS
      foreground
      {
        sleep 1
      }
      "echo"
      "Homebrew"
    EOS
    assert_match "Homebrew", shell_output("#{bin}/execlineb test.eb")
  end
end
