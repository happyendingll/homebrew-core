class Nift < Formula
  desc "Fast dependency-aware website generator"
  homepage "https://nift.dev/"
  url "https://github.com/nift-dev/nift/archive/refs/tags/v4.1.0.tar.gz"
  sha256 "3f168d8e9f780db306a61a30afc55273f2766c31f754f79177b5406b77dd47d9"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "b23db7c1d5615768768f56aec0675c038faa689ddc611c1f868fc05b2e9debed"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ee6fa1aad62b1e84e984a3ac1bb8783930745b2bb4f60b15696dbfde8c3e2e71"
    sha256 cellar: :any,                 arm64_sequoia:     "80955503208a4e101cb981c285a30cc163d40e3a85f93b892ad26302fffa9a39"
    sha256 cellar: :any,                 arm64_linux:       "24128b951b65c2a17014a3eb7b430ec431338ee8ef19548c1af5ddd93b635694"
    sha256 cellar: :any,                 x86_64_linux:      "fc61e378e35c7b93678ef3fbff0d76c578bd42ed2ccd7310ec10403c1ba9b349"
  end

  on_sequoia :or_older do
    depends_on "llvm"

    fails_with :clang do
      cause "floating-point `std::from_chars` requires macOS 26 libc++"
    end
  end

  def install
    if OS.mac? && MacOS.version <= :sequoia
      # Link LLVM's libc++ as the system one lacks floating-point `std::from_chars` before macOS 26
      ENV.prepend_path "HOMEBREW_LIBRARY_PATHS", formula_opt_lib("llvm")/"c++"
      inreplace "Makefile", /^CXXFLAGS \?= /, "\\0-D_LIBCPP_DISABLE_AVAILABILITY "
    end

    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system bin/"nift", "init", "--ext=.html"
    assert_path_exists testpath/"public/index.html"
  end
end
