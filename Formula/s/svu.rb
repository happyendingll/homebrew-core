class Svu < Formula
  desc "Semantic version utility"
  homepage "https://github.com/caarlos0/svu"
  url "https://github.com/caarlos0/svu/archive/refs/tags/v3.4.4.tar.gz"
  sha256 "2b1a2fc5bf804c80a9261686370bf882dcc092b1cb8e1605920fce7da7562f0e"
  license "MIT"
  head "https://github.com/caarlos0/svu.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "ab26a41d0cc65855be078d7fb63c05a7ff79503edcb1229eb661e390f4ece2a9"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X main.version=#{version} -X main.commit=#{tap.user} -X main.date=#{time.iso8601} -X main.builtBy=#{tap.user} -X main.treeState=clean"
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"svu", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/svu --version")
    system bin/"svu", "init"
    assert_match "svu configuration", (testpath/".svu.yml").read
  end
end
