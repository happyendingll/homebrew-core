class Bear < Formula
  desc "Generate compilation database for clang tooling"
  homepage "https://github.com/rizsotto/Bear"
  url "https://github.com/rizsotto/Bear/archive/refs/tags/4.2.4.tar.gz"
  sha256 "1a771dba88f9687e58b6c35537336bab7a26dc196b2d37f868c7a83a310ab959"
  license "GPL-3.0-or-later"
  head "https://github.com/rizsotto/Bear.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "71ac5c6197eb7c3d0d5d008d48c74684c70c0715d98dc9e8da0a1ee2eda816b9"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "lld" => :build
    depends_on "llvm" => :test
  end

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    %w[driver wrapper].each do |crate|
      # Install binaries to `target/release` because `scripts/install.sh` expects them here
      system "cargo", "install", *std_cargo_args(root: "target/release", path: "crates/bear-#{crate}")
    end
    ENV.append_to_rustflags "-C link-arg=-fuse-ld=lld" if OS.linux?
    system "cargo", "build", "--jobs", ENV.make_jobs, "--lib", "--release"

    with_env(PREFIX: prefix) do
      system "scripts/install.sh"
    end
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      int main() {
        printf("hello, world!\\n");
        return 0;
      }
    C
    system bin/"bear", "--", "clang", "test.c"
    assert_path_exists testpath/"compile_commands.json"
  end
end
