class PvMigrate < Formula
  desc "CLI tool to migrate or backup/restore Kubernetes persistent volumes"
  homepage "https://github.com/utkuozdemir/pv-migrate"
  url "https://github.com/utkuozdemir/pv-migrate/archive/refs/tags/v3.8.0.tar.gz"
  sha256 "7727a832439d75933d7ee92c8863a0c1f93299bfea0e7e6e744ce16b64f2c629"
  license "Apache-2.0"
  head "https://github.com/utkuozdemir/pv-migrate.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "9f1a73a11dda2c73aa86fe73f2f0a51f4fbf3403504fbd531c364bb8034df031"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/pv-migrate"

    generate_completions_from_executable(bin/"pv-migrate", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pv-migrate --version")
    output = shell_output("#{bin}/pv-migrate migrate 2>&1", 1)
    assert_match "source", output.downcase
  end
end
