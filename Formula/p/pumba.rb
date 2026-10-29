class Pumba < Formula
  desc "Chaos testing tool for Docker"
  homepage "https://github.com/alexei-led/pumba"
  url "https://github.com/alexei-led/pumba/archive/refs/tags/1.3.0.tar.gz"
  sha256 "f2f84bf57d97e5c4cf90307c7f1db284c0e4a25a42ac5d8c864af9cd0169303f"
  license "Apache-2.0"
  head "https://github.com/alexei-led/pumba.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "f9d0bf4add8a5be45644c06dfa00ec910cb56ae2bb28522cc5da1d935b1f1921"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f9d0bf4add8a5be45644c06dfa00ec910cb56ae2bb28522cc5da1d935b1f1921"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f9d0bf4add8a5be45644c06dfa00ec910cb56ae2bb28522cc5da1d935b1f1921"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "363a886bfb0517e6ca6cdb6e7b7154a266a3ac58e71eb11c46953d440e5d7835"
    sha256 cellar: :any,                 x86_64_linux:      "10fba1b46a4e3070ecd8d013703de58284daef6d075d54121cee1d61b803ec0f"
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
