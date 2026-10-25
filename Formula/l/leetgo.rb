class Leetgo < Formula
  desc "CLI tool for LeetCode"
  homepage "https://github.com/j178/leetgo"
  url "https://github.com/j178/leetgo/archive/refs/tags/v1.5.2.tar.gz"
  sha256 "d196b7daa0f5ecd49a9dfb735650d7ff8f4ab2df4ce8e3b4d0ec1cd00a457c61"
  license "MIT"
  head "https://github.com/j178/leetgo.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "03fe915d398d6ffa7f00b7e66addf6091539cb7db3eccdf0855d924babecf905"
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
