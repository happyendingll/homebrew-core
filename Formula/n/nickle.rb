class Nickle < Formula
  desc "Desk calculator language"
  homepage "https://www.nickle.org/"
  url "https://nickle.org/release/nickle-2.113.tar.xz"
  sha256 "994e5658cab6aa9525a52ac38d220d26854808b4afdfec0beac0840325433d17"
  license "MIT"

  livecheck do
    url "https://nickle.org/release/"
    regex(/href=.*?nickle[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "1ad5abb9d2a425081ae9461191b12039913d538be6a031d10a9b8633333d1861"
  end

  depends_on "bison" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "gmp"

  uses_from_macos "bc-gh" => :build
  uses_from_macos "flex" => :build
  uses_from_macos "libedit"

  # Remove an unused declaration that conflicts with Flex's input function.
  patch do
    url "https://github.com/keith-packard/nickle/commit/1d319e603813f3a78ec83440584a901d603346e8.patch?full_index=1"
    sha256 "04828738e17813ebd5fd9aa9e38a549f2b5de9a707bdf1b6ae062c5d5d1388b9"
    type :unofficial
    resolves "https://github.com/keith-packard/nickle/pull/1"
  end

  def install
    # Fix to ERROR: None of values ['gnu23'] are supported by the C compiler
    inreplace "meson.build", "c_std=gnu23", "c_std=gnu2x"

    system "meson", "setup", "build", "-Dlibedit=true", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    assert_equal "4", shell_output("#{bin}/nickle -e '2+2'").chomp
  end
end
