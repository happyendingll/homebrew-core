class Assh < Formula
  desc "Advanced SSH config - Regex, aliases, gateways, includes and dynamic hosts"
  homepage "https://v1.manfred.life/assh/"
  url "https://github.com/moul/assh/archive/refs/tags/v2.17.4.tar.gz"
  sha256 "8fb62ecf5dbc3369cca56cebe9298c84791c688b05f98d155dc58ac208f541f2"
  license "MIT"
  head "https://github.com/moul/assh.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "d4d29ccd3137433e9d1e43d74724ce16c8fc5fd7129246c7643b76e33741ab1e"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args

    generate_completions_from_executable(bin/"assh", shell_parameter_format: :cobra)
  end

  test do
    assh_config = testpath/"assh.yml"
    assh_config.write <<~YAML
      hosts:
        hosta:
          Hostname: 127.0.0.1
      asshknownhostfile: /dev/null
    YAML

    output = "hosta assh ping statistics"
    assert_match output, shell_output("#{bin}/assh --config #{assh_config} ping -c 4 hosta 2>&1")
  end
end
