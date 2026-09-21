class Oxipng < Formula
  desc "Multithreaded PNG optimizer written in Rust"
  homepage "https://github.com/oxipng/oxipng"
  url "https://github.com/oxipng/oxipng/archive/refs/tags/v10.2.1.tar.gz"
  sha256 "460ccfcdcc9c3877b9f7fae1dfd4f2a3f93d3b2a2af3e3b62ca32b163f923cca"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "201c86f38ee9151ef7e5b381a8de63cce489c60dd52780090b39114a814b25e5"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
    # `xtask` (used for man page generation) is a standalone manifest with its
    # own lockfile, outside the root workspace.
    system "cargo", "fetch", *std_cargo_fetch_args, "--manifest-path", "xtask/Cargo.toml"
  end

  def install
    system "cargo", "install", *std_cargo_args
    system "cargo", "run",
           "--manifest-path", "xtask/Cargo.toml",
           "--jobs", ENV.make_jobs.to_s,
           "--locked", "--", "mangen"

    man1.install "target/xtask/mangen/manpages/oxipng.1"
  end

  test do
    system bin/"oxipng", "--dry-run", test_fixtures("test.png")
  end
end
