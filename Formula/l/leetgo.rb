class Leetgo < Formula
  desc "CLI tool for LeetCode"
  homepage "https://github.com/j178/leetgo"
  url "https://github.com/j178/leetgo/archive/refs/tags/v1.4.19.tar.gz"
  sha256 "39537b3d2e221c5cec3826c845711903223fb878e93f81a1b452d814c806c819"
  license "MIT"
  head "https://github.com/j178/leetgo.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "ff2512df56b5cda43b814363e2c69b6dc03c22018a8c7c5291d9397760489724"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/j178/leetgo/constants.Version=#{version}
      -X github.com/j178/leetgo/constants.Commit=#{tap.user}
      -X github.com/j178/leetgo/constants.BuildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)
    generate_completions_from_executable(bin/"leetgo", shell_parameter_format: :cobra)
  end

  test do
    assert_match "leetgo version #{version}", shell_output("#{bin}/leetgo --version")
    system bin/"leetgo", "init", "--site", "us"
    assert_path_exists testpath/"leetgo.yaml"
  end
end
