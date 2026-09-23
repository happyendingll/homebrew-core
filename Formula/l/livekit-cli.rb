class LivekitCli < Formula
  desc "Command-line interface to LiveKit"
  homepage "https://livekit.io"
  url "https://github.com/livekit/livekit-cli/archive/refs/tags/v2.18.8.tar.gz"
  sha256 "db9aa392805ffbdd0ae9372edf1a94b0f17bbaa9646bf2f58d24a914e0d5b737"
  license "Apache-2.0"
  head "https://github.com/livekit/livekit-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "579acf45269bf8afc54e666342c874cf87955d614218d99494fcb16348b41bf5"
  end

  depends_on "go" => :build
  depends_on "pkgconf" => :build
  depends_on "portaudio"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1"
    system "go", "build", *std_go_args(tags: "portaudio_system", output: bin/"lk"), "./cmd/lk"

    bin.install_symlink "lk" => "livekit-cli"

    bash_completion.install "autocomplete/bash_autocomplete" => "lk"
    fish_completion.install "autocomplete/fish_autocomplete" => "lk.fish"
    zsh_completion.install "autocomplete/zsh_autocomplete" => "_lk"
  end

  test do
    output = shell_output("#{bin}/lk token create --list --api-key key --api-secret secret 2>&1")
    assert_match "valid for (mins): 5", output
    assert_match "lk version #{version}", shell_output("#{bin}/lk --version")
  end
end
