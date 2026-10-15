class Zizmor < Formula
  desc "Find security issues in GitHub Actions setups"
  homepage "https://docs.zizmor.sh/"
  url "https://github.com/zizmorcore/zizmor/archive/refs/tags/v1.31.0.tar.gz"
  sha256 "bdc0f89c667f599cf96e76e1016ac04b75044fc3a93387eec19b2f8414271feb"
  license "MIT"
  head "https://github.com/zizmorcore/zizmor.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "f0e0b813359315af0e3f18acc393eb11beb65da6083c8f533fac5dc91565d146"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3b9da4fa5f8f6a8226495c8ed9957cbec00f076060f6da63519ed4a402e798e2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "9eae2f375009e26a5c91532ac94d1db49175988caa0eb90f1538641c7481511e"
    sha256 cellar: :any,                 arm64_linux:       "1952e9c674bfa7f7a604fc07d79e33292fcfffb72f672c49114f0063cdf7ad28"
    sha256 cellar: :any,                 x86_64_linux:      "7e565ea12c316a3e55201076d338752762a9d03234104ad64713b352fb682e5b"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
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
