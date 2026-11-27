class Descope < Formula
  desc "Command-line utility for performing common tasks on Descope projects"
  homepage "https://www.descope.com"
  url "https://github.com/descope/descopecli/archive/refs/tags/v0.8.18.tar.gz"
  sha256 "41c3af732258df9b8e5f786c4c73dfc0a9c5b16911904ae6d5800454da7eb36b"
  license "MIT"
  head "https://github.com/descope/descopecli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "c51440d3dc497bf86cc7b31b08d577d007d1004c3a4fb100712c141d0f6d433d"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
    generate_completions_from_executable(bin/"descope", shell_parameter_format: :cobra)
  end

  test do
    assert_match "working with audit logs", shell_output("#{bin}/descope audit")
    assert_match "managing projects", shell_output("#{bin}/descope project")
    assert_match version.to_s, shell_output("#{bin}/descope --version")
  end
end
