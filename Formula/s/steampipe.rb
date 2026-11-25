class Steampipe < Formula
  desc "Use SQL to instantly query your cloud services"
  homepage "https://steampipe.io/"
  url "https://github.com/turbot/steampipe/archive/refs/tags/v2.5.3.tar.gz"
  sha256 "76ad372e658406ca38c2cb4bf5b2f79cf5068aaddb6a2c21d638cb8256ef16c1"
  license "AGPL-3.0-only"
  head "https://github.com/turbot/steampipe.git", branch: "develop"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "60898bce84ddea1e8050fd5a9ce5ae757e6c168e5b665ca5b8a2c7b170b70bfb"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X main.version=#{version} -X main.date=#{time.iso8601} -X main.commit=#{tap.user}"
    system "go", "build", *std_go_args(ldflags:, tags: "http2legacy")

    generate_completions_from_executable(bin/"steampipe", shell_parameter_format: :cobra)
  end

  test do
    ENV["STEAMPIPE_INSTALL_DIR"] = testpath

    output = shell_output("#{bin}/steampipe service status")
    assert_match "Steampipe service is not installed", output

    assert_match version.to_s, shell_output("#{bin}/steampipe --version")
  end
end
