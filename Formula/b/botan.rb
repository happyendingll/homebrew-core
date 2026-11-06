class Botan < Formula
  desc "Cryptographic algorithms and formats library in C++"
  homepage "https://botan.randombit.net/"
  url "https://botan.randombit.net/releases/Botan-3.14.0.tar.xz"
  sha256 "c22d66a08cd3c6dae683bdcb8384beaa9e2cbd75821e19a270047030fbe81ac7"
  license "BSD-2-Clause"
  compatibility_version 4
  head "https://github.com/randombit/botan.git", branch: "master"

  livecheck do
    url :homepage
    regex(/href=.*?Botan[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 sequoia: "f974c17cf56cab586f41af5ffb3dc6fc563843ebfca55ad1504fcf7f0ba57983"
  end

  depends_on "pkgconf" => :build
  depends_on "ca-certificates"
  depends_on "python@3.15"
  depends_on "sqlite"

  uses_from_macos "bzip2"

  on_macos do
    depends_on "llvm" if DevelopmentTools.clang_build_version <= 1400
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  fails_with :clang do
    build 1400
    cause "Requires C++20"
  end

  def install
    ENV.runtime_cpu_detection

    args = %W[
      --prefix=#{prefix}
      --docdir=share/doc
      --with-zlib
      --with-bzip2
      --with-sqlite3
      --system-cert-bundle=#{Formula["ca-certificates"].pkgetc}/cert.pem
    ]
    if OS.mac?
      args << "--with-commoncrypto"
      # The CLI's `sandbox_init` profile constants were removed from the macOS 27 SDK
      args << "--without-os-features=sandbox_proc"
    end

    if OS.mac? && DevelopmentTools.clang_build_version <= 1400
      ldflags = %W[-L#{formula_opt_lib("llvm")}/c++ -L#{formula_opt_lib("llvm")}/unwind -lunwind]
      args << "--ldflags=#{ldflags.join(" ")}"
    end

    system python3, "configure.py", *args
    system "make", "install"
  end

  test do
    text = "Homebrew"
    base64_enc = pipe_output("#{bin}/botan base64_enc -", text)
    refute_empty base64_enc
    assert_equal text, pipe_output("#{bin}/botan base64_dec -", base64_enc).chomp
  end
end
