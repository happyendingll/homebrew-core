class ConsulTemplate < Formula
  desc "Generic template rendering and notifications with Consul"
  homepage "https://github.com/hashicorp/consul-template"
  url "https://github.com/hashicorp/consul-template/archive/refs/tags/v0.43.0.tar.gz"
  sha256 "95b2f441437ceafb8dadea03aa62589d78fd03d0dc31005cf51d4042c3d6fe74"
  license "MPL-2.0"
  head "https://github.com/hashicorp/consul-template.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "e9d5654ad0dc253bac17a8b2c5ff4217e70efd3b293a389ce64c772ec8edd744"
  end

  depends_on "go" => :build

  def install
    project = "github.com/hashicorp/consul-template"
    ldflags = %W[
      -X #{project}/version.Name=consul-template
      -X #{project}/version.GitCommit=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    (testpath/"template").write <<~EOS
      {{"homebrew" | toTitle}}
    EOS
    system bin/"consul-template", "-once", "-template", "template:test-result"
    assert_equal "Homebrew", (testpath/"test-result").read.chomp
  end
end
