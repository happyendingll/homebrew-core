class Clifm < Formula
  desc "Command-line Interface File Manager"
  homepage "https://github.com/leo-arch/clifm"
  url "https://github.com/leo-arch/clifm/archive/refs/tags/v1.29.tar.gz"
  sha256 "dfdc0f339437345d9d5d8c2cb4bd43294c05821ebc8d5f0c9abfa4eec8f6c905"
  license "GPL-2.0-or-later"

  # Upstream creates releases that use a stable tag (e.g., `v1.2.3`) but are
  # labeled as "pre-release" on GitHub before the version is released, so it's
  # necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "950ea4d676be0ed93645494f2ae29b971ed7e1fa7d1b6877d696b6ff7704ecb4"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "libmagic"
  depends_on "readline"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "acl"
    depends_on "libcap"
  end

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # fix `clifm: dumb: Unsupported terminal.` error
    ENV["TERM"] = "xterm"

    output = shell_output("#{bin}/clifm nonexist 2>&1", 2)
    assert_match "clifm: 'nonexist': No such file or directory", output
    assert_match version.to_s, shell_output("#{bin}/clifm --version")
  end
end
