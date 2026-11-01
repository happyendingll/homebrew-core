class Nebula < Formula
  desc "Scalable overlay networking tool for connecting computers anywhere"
  homepage "https://github.com/slackhq/nebula"
  url "https://github.com/slackhq/nebula/archive/refs/tags/v1.12.0.tar.gz"
  sha256 "f4d33fbe0a57d2914b8cc94b463d3f170990f92f34251aaef1ca80fb5cd952b0"
  license "MIT"
  head "https://github.com/slackhq/nebula.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "928dc8fe00f7a7fef4140e6abaa107bc06f0cf78c2a4e12adbc6e7198fe2f232"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = "-X main.Build=#{version}"
    system "go", "build", *std_go_args(ldflags:, output: bin/"nebula"), "./cmd/nebula-service"
    system "go", "build", *std_go_args(ldflags:, output: bin/"nebula-cert"), "./cmd/nebula-cert"
  end

  service do
    run [opt_bin/"nebula", "-config", etc/"nebula/"]
    keep_alive true
    require_root true
    log_path var/"log/nebula.log"
    error_log_path var/"log/nebula.log"
  end

  test do
    system bin/"nebula-cert", "ca", "-name", "testorg"
    system bin/"nebula-cert", "sign", "-name", "host", "-ip", "192.168.100.1/24"
    (testpath/"config.yml").write <<~YAML
      pki:
        ca: #{testpath}/ca.crt
        cert: #{testpath}/host.crt
        key: #{testpath}/host.key
    YAML
    system bin/"nebula", "-test", "-config", "config.yml"
  end
end
