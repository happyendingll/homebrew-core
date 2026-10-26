class Amass < Formula
  desc "In-depth attack surface mapping and asset discovery"
  homepage "https://owasp.org/www-project-amass/"
  url "https://github.com/owasp-amass/amass/archive/refs/tags/v5.1.2.tar.gz"
  sha256 "7b3dc9b8954f29f3bdfd74bf2fa6d8ab6737e6443b5b283ce3e19d172fe2d08e"
  license "Apache-2.0"
  head "https://github.com/owasp-amass/amass.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "324dae4c49c6bd7bce3239d92fb37ebb71fbddbc204626d29401405093a299c9"
  end

  depends_on "go" => :build

  # `test do` block performs DNS enumeration
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    # TODO: check if version patch is still needed in next release
    # https://github.com/owasp-amass/amass/issues/1157
    inreplace "internal/afmt/print.go", "Version = \"v5.1.1\"", "Version = \"v#{version}\""

    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args, "./cmd/amass"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/amass --version 2>&1")

    (testpath/"config.yaml").write <<~YAML
      scope:
        domains:
          - example.com
    YAML

    system bin/"amass", "enum", "-list", "-config", testpath/"config.yaml"
  end
end
