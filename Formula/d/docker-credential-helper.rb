class DockerCredentialHelper < Formula
  desc "Platform keystore credential helper for Docker"
  homepage "https://github.com/docker/docker-credential-helpers"
  url "https://github.com/docker/docker-credential-helpers/archive/refs/tags/v0.9.13.tar.gz"
  sha256 "b5bdcd9fe7539cbb4feb90aaf734e76c1232cd9ec5f0c976ad549657f53d7048"
  license "MIT"
  head "https://github.com/docker/docker-credential-helpers.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "226e9a634e01983fd8ba414ec7acf3a8f1e65c4e07cba3aff6c6ad846825193b"
  end

  depends_on "go" => :build
  depends_on "pkgconf" => :build

  on_linux do
    depends_on "glib"
    depends_on "libsecret"
  end

  deny_network_access!

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    if OS.mac?
      system "make", "osxkeychain"
      bin.install "bin/build/docker-credential-osxkeychain"
    else
      system "make", "secretservice"
      bin.install "bin/build/docker-credential-secretservice"
    end
    system "make", "pass"
    bin.install "bin/build/docker-credential-pass"
  end

  test do
    if OS.mac?
      run_output = shell_output("#{bin}/docker-credential-osxkeychain", 1)
      assert_match "Usage: docker-credential-osxkeychain", run_output
    else
      run_output = shell_output("#{bin}/docker-credential-secretservice list", 1)
      assert_match "Cannot autolaunch D-Bus without X11", run_output
    end
    run_output = shell_output("#{bin}/docker-credential-pass list")
    assert_match "{}", run_output
  end
end
