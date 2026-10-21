class Stencil < Formula
  desc "Modern living-template engine for evolving repositories"
  homepage "https://stencil.rgst.io"
  url "https://git.rgst.io/rgst-io/stencil/archive/v3.0.3.tar.gz"
  sha256 "93ae08d70bb6fccd6c659532963d5be49eb650f9fcf909c598ceea893d4216a9"
  license "Apache-2.0"
  head "https://git.rgst.io/rgst-io/stencil.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "437500d2ed739d812259a930d51c4dd8adb2e0b2b17efe037373198e51f980e5"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X go.rgst.io/stencil/v3/internal/version.version=#{version}
      -X go.rgst.io/stencil/v3/internal/version.builtBy=#{tap.user}
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/stencil"
    generate_completions_from_executable(bin/"stencil", "completion",
                                          shell_parameter_format: "",
                                          shells:                 [:bash, :zsh, :fish, :pwsh])
  end

  test do
    (testpath/"service.yaml").write "name: test"
    system bin/"stencil"
    assert_path_exists testpath/"stencil.lock"
  end
end
