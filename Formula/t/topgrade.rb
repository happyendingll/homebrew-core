class Topgrade < Formula
  desc "Upgrade all the things"
  homepage "https://github.com/topgrade-rs/topgrade"
  url "https://github.com/topgrade-rs/topgrade/archive/refs/tags/v17.13.0.tar.gz"
  sha256 "ec055df2751471229f9891d012686703afca2e525b3bff49fa2ae8a77bfe23c9"
  license "GPL-3.0-or-later"
  head "https://github.com/topgrade-rs/topgrade.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  no_autobump! because: :bumped_by_upstream

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "bc5d6f7770083e899edb998808a4e8c3192e6092a06c117b55e9bbdb77399d2b"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "948fa4a79c6f1178f37272de5becadaeca07e8d50aaa28bd8d825293777f820b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "4f248fc765762836b32904362a94120963ef557a8b03234e6b0af6aed6a726c9"
    sha256 cellar: :any,                 arm64_linux:       "046b64ecf79c0f2bc7b0579df126baf9b17fb15a8c587bb5185f9dd2aa31eab3"
    sha256 cellar: :any,                 x86_64_linux:      "b782f7a658de1beea7d8322e13cf81d6e8674cdf00054012d4234c177da07bb7"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"topgrade", "--gen-completion")
    (man1/"topgrade.1").write Utils.safe_popen_read(bin/"topgrade", "--gen-manpage")
  end

  test do
    ENV["TOPGRADE_SKIP_BRKC_NOTIFY"] = "true"
    assert_match version.to_s, shell_output("#{bin}/topgrade --version")

    output = shell_output("#{bin}/topgrade -n --only brew_formula")
    assert_match %r{Dry running: (?:#{HOMEBREW_PREFIX}/bin/)?brew upgrade}o, output
    refute_match(/\sSelf update\s/, output)
  end
end
