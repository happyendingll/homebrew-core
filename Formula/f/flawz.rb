class Flawz < Formula
  desc "Terminal UI for browsing security vulnerabilities (CVEs)"
  homepage "https://github.com/orhun/flawz"
  url "https://github.com/orhun/flawz/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "641264999d2a5d662bc3d9c3994fcc580b92a2e9051c79fbcb8fdb2220924f30"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/orhun/flawz.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "f7be5c74ebb5a7624dcda9e23e5d39f28702c8a6ea1424a810efcfdcbeca775a"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "sqlite"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    # Setup buildpath for completions and manpage generation
    ENV["OUT_DIR"] = buildpath

    system bin/"flawz-completions"
    bash_completion.install "flawz.bash" => "flawz"
    fish_completion.install "flawz.fish"
    zsh_completion.install "_flawz"

    system bin/"flawz-mangen"
    man1.install "flawz.1"

    # no need to ship `flawz-completions` and `flawz-mangen` binaries
    rm [bin/"flawz-completions", bin/"flawz-mangen"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/flawz --version")

    require "pty"
    output_log = testpath/"output.log"
    pid = PTY.spawn(bin/"flawz", [:out, :err] => output_log.to_s).last
    sleep 2
    assert_match "Syncing CVE Data", output_log.read
  ensure
    Process.kill "TERM", pid
    Process.wait pid
  end
end
