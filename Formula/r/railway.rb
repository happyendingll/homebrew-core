class Railway < Formula
  desc "Develop and deploy code with zero configuration"
  homepage "https://railway.com/"
  url "https://github.com/railwayapp/cli/archive/refs/tags/v5.57.4.tar.gz"
  sha256 "03cea10e169ae7247169910ed6e4c9a4ad0e0ace8a2675f1d314efb51dfda4e2"
  license "MIT"
  head "https://github.com/railwayapp/cli.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "d342b6a3fe6a331ac7ac478ee1a4f7af878a9a96411ace7dc76bbbfe4d0895ad"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "05484a85e905e0a3f0a993fb87739f62313d659e54db95e18265ffc3e26dddcb"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "b22a7c95e318db160011d28e9727ef2bce4c23f2760b5c246b7cb694e666ca7a"
    sha256 cellar: :any,                 arm64_linux:       "9884731fe0a32d74192d097f4cbbc0ffdfdfc7c58c3d1d9018586a12e0533d02"
    sha256 cellar: :any,                 x86_64_linux:      "2953528872b7e3cf9b185e43054b753583a59c03e15cac500cf96a380b99a6f1"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"
  end

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"railway", "completion")
  end

  test do
    output = shell_output("#{bin}/railway init 2>&1", 1).chomp
    assert_match "Unauthorized. Please login with `railway login`", output

    assert_equal "railway #{version}", shell_output("#{bin}/railway --version").strip
  end
end
