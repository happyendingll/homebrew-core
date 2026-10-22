class Zigmod < Formula
  desc "Package manager for the Zig programming language"
  homepage "https://nektro.github.io/zigmod/"
  url "https://github.com/nektro/zigmod/archive/refs/tags/r106.tar.gz"
  version "r106"
  sha256 "faea9f58a0cf9f582d51ebd7252b624e062c1bb6e41ea98bddbe4592005999ae"
  license "MIT"
  version_scheme 1

  livecheck do
    url :stable
    regex(/^(r\d+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "7a4549966cc05cd9265bb06b8acc4372821c311011dcbb9331ee0c606f46d8a3"
  end

  depends_on "git" => :build # `zig build fetch` runs `git clone --revision` (git 2.49+)
  depends_on "zig"

  deny_network_access!

  def fetch
    system "zig", "build", "fetch", "-Dtag=#{version}"
  end

  def install
    args = %W[
      -Dtag=#{version}
      -Dstrip=true
    ]

    system "zig", "build", *args, *std_zig_args
  end

  test do
    (testpath/"dependency/src").mkpath
    (testpath/"dependency/zigmod.yml").write <<~YAML
      id: 8w9skd2bi3x7vh6z6xcu3taaz1tww2ghbjt5p1e9fyj1pgsu
      name: zigmod-test-dependency
      main: src/lib.zig
      license: MIT
      description: Test zig.mod dependency
      min_zig_version: 0.11.0
      min_zigmod_version: #{version}
      dependencies:
    YAML
    (testpath/"dependency/src/lib.zig").write <<~ZIG
      pub fn message() []const u8 {
        return "Hello from zigmod dependency!";
      }
    ZIG
    system "git", "-C", testpath/"dependency", "init"
    system "git", "-C", testpath/"dependency", "add", "."
    system "git", "-C", testpath/"dependency", "-c", "user.name=Homebrew",
                  "-c", "user.email=brew@test-bot.local", "commit", "-m", "init"

    (testpath/"zigmod.yml").write <<~YAML
      id: 89ujp8gq842x6mzok8feypwze138n2d96zpugw44hcq7406r
      name: zigmod
      main: src/lib.zig
      license: MIT
      description: Test zig.mod
      min_zig_version: 0.11.0
      dependencies:
        - src: git #{testpath}/dependency
    YAML

    (testpath/"src/lib.zig").write <<~ZIG
      const std = @import("std");
      pub fn main() !void {
        std.log.info("Hello, world!");
      }
    ZIG

    system bin/"zigmod", "fetch"
    assert_path_exists testpath/"deps.zig"
    assert_path_exists testpath/"zigmod.lock"

    assert_match version.to_s, shell_output("#{bin}/zigmod version")
  end
end
