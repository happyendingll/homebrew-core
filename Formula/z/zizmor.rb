class Zizmor < Formula
  desc "Find security issues in GitHub Actions setups"
  homepage "https://docs.zizmor.sh/"
  url "https://github.com/zizmorcore/zizmor/archive/refs/tags/v1.30.1.tar.gz"
  sha256 "3224fd5b49b77b2ec1a8a0809587824e3bc346a7583e8272d8ad66f95d0e8cc2"
  license "MIT"
  head "https://github.com/zizmorcore/zizmor.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "96037e9c3f93a9055e1868c0ee4ae5c0c45e235bb986228f48a82e88527dc978"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/zizmor")

    generate_completions_from_executable(bin/"zizmor", shell_parameter_format: "--completions=")
  end

  test do
    (testpath/"workflow.yaml").write <<~YAML
      on: push
      jobs:
        vulnerable:
          runs-on: ubuntu-latest
          steps:
            - name: Checkout
              uses: actions/checkout@v4
    YAML

    output = shell_output("#{bin}/zizmor --format plain #{testpath}/workflow.yaml", 14)
    assert_match "does not set persist-credentials: false", output
  end
end
