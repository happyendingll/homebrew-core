class Delve < Formula
  desc "Debugger for the Go programming language"
  homepage "https://github.com/go-delve/delve"
  url "https://github.com/go-delve/delve/archive/refs/tags/v1.27.2.tar.gz"
  sha256 "8ea5979dfc5978c9690dc1dd533a830815441dd33617f4a61bcdff7d2c3c7e90"
  license "MIT"
  head "https://github.com/go-delve/delve.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "9c02a4fb320af82c943f0dba6c58afdaecd9fccfd69d1a6ed3a2000739aa3742"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(output: bin/"dlv"), "./cmd/dlv"

    generate_completions_from_executable(bin/"dlv", shell_parameter_format: :cobra)
  end

  test do
    assert_match(/^Version: #{version}$/, shell_output("#{bin}/dlv version"))
  end
end
