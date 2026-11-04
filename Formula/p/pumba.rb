class Pumba < Formula
  desc "Chaos testing tool for Docker"
  homepage "https://github.com/alexei-led/pumba"
  url "https://github.com/alexei-led/pumba/archive/refs/tags/1.5.1.tar.gz"
  sha256 "12e67020a477a25a73ffa15a6a48b1df0bf4c43137e51f59a760f55db624e150"
  license "Apache-2.0"
  head "https://github.com/alexei-led/pumba.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "c12b8f59eea7b9abceae7eb3d21a60dcd73d6328291ae781e31bc2ad48092db8"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pumba --version")

    # Linux CI container on GitHub actions exposes Docker socket but lacks permissions to read
    expected = if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]
      "/var/run/docker.sock: connect: permission denied"
    else
      "Is the docker daemon running?"
    end

    assert_match expected, shell_output("#{bin}/pumba rm test-container 2>&1", 1)
  end
end
