class Aliae < Formula
  desc "Cross shell and platform alias management"
  homepage "https://aliae.dev"
  url "https://github.com/jandedobbeleer/aliae/archive/refs/tags/v1.6.0.tar.gz"
  sha256 "f19a45be5d135474635e488cfa687163eaafc432f8cac4b2b8c566fb216d7e88"
  license "MIT"
  head "https://github.com/jandedobbeleer/aliae.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "319afe1af1e79d7e66ca36a4ef71c62a728a52d364ace93795f34c20fef4c7ae"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    cd "src" do
      system "go", "mod", "download"
    end
  end

  def install
    cd "src" do
      system "go", "build", *std_go_args(ldflags: "-X main.Version=#{version}")
    end

    generate_completions_from_executable(bin/"aliae", shell_parameter_format: :cobra)
  end

  test do
    (testpath/".aliae.yaml").write <<~YAML
      alias:
        - name: a
          value: aliae
        - name: hello-world
          value: echo "hello world"
          type: function
    YAML

    output = shell_output("#{bin}/aliae init bash")
    assert_equal <<~SHELL.chomp, output
      alias a="aliae"
      hello-world() {
          echo "hello world"
      }
    SHELL

    assert_match version.to_s, shell_output("#{bin}/aliae --version")
  end
end
