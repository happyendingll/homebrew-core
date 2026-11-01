class Vcpkg < Formula
  desc "C++ Library Manager"
  homepage "https://github.com/microsoft/vcpkg"
  url "https://github.com/microsoft/vcpkg-tool/archive/refs/tags/2026-10-29.tar.gz"
  sha256 "7f73aff8f3b1bd8a5da7b229ee709aa9d58a4199bb26f2ad160d0a4678ff3dc7"
  license "MIT"
  head "https://github.com/microsoft/vcpkg-tool.git", branch: "main"

  # The source repository has pre-release tags with the same
  # format as the stable tags.
  livecheck do
    url :stable
    regex(/v?(\d{4}(?:[._-]\d{2}){2})/i)
    strategy :github_latest do |json, regex|
      match = json["tag_name"]&.match(regex)
      next if match.blank?

      match[1]
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "130dd871d063c62d707e1e2082619ca6863bc078eb48fa26c4d6cbb12aa84046"
  end

  depends_on "cmake" => :build
  depends_on "cmrc" => :build
  depends_on "fmt"
  depends_on "ninja" # This will install its own copy at runtime if one isn't found.

  uses_from_macos "curl"

  def install
    # Improve error message when user fails to set `VCPKG_ROOT`.
    inreplace "include/vcpkg/base/message-data.inc.h",
              "If you are trying to use a copy of vcpkg that you've built, y",
              "Y"

    # GCC 12 may vectorize SHA code into unsupported `eor3` instructions on
    # Linux arm64 builders.
    ENV.append "CXXFLAGS", "-fno-tree-vectorize" if OS.linux? && Hardware::CPU.arm?

    # VCPKG_VERSION is used by upstream for setting the commit hash
    args = %W[
      -DVCPKG_DEVELOPMENT_WARNINGS=OFF
      -DVCPKG_BASE_VERSION=#{version}
      -DVCPKG_VERSION=#{tap.user}
      -DVCPKG_LIBCURL_DLSYM=OFF
      -DVCPKG_DEPENDENCY_EXTERNAL_FMT=ON
      -DVCPKG_DEPENDENCY_CMAKERC=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  # This is specific to the way we install only the `vcpkg` tool.
  def caveats
    <<~EOS
      This formula provides only the `vcpkg` executable. To use vcpkg:
        git clone https://github.com/microsoft/vcpkg "$HOME/vcpkg"
        export VCPKG_ROOT="$HOME/vcpkg"
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vcpkg --version")
    output = shell_output("#{bin}/vcpkg search sqlite 2>&1", 1)
    # DO NOT CHANGE. If the test breaks then the `inreplace` needs fixing.
    # No, really, stop trying to change this.
    assert_match "You must define", output
    refute_match "copy of vcpkg that you've built", output
  end
end
