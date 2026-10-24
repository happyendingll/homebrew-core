class LivekitCli < Formula
  desc "Command-line interface to LiveKit"
  homepage "https://livekit.io"
  url "https://github.com/livekit/livekit-cli/archive/refs/tags/v2.19.2.tar.gz"
  sha256 "db92f4b7adb33c5bd9f838ea7d7c6b75b141e49934c876a3449d6c9fe397f788"
  license "Apache-2.0"
  head "https://github.com/livekit/livekit-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "6d308f837729cd3c49c4fb50fc153442612bd066c7cf849d01bdc80efd742b83"
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
    zsh_completion.install "autocomplete/zsh_autocomplete" => "_lk"
    generate_completions_from_executable(bin/"lk", "generate-fish-completion",
                                         shell_parameter_format: :none, shells: [:fish])
  end

  test do
    output = shell_output("#{bin}/lk token create --list --api-key key --api-secret secret 2>&1")
    assert_match "valid for (mins): 5", output
    assert_match "lk version #{version}", shell_output("#{bin}/lk --version")
  end
end
