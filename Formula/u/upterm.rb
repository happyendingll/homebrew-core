class Upterm < Formula
  desc "Instant terminal sharing"
  homepage "https://upterm.dev"
  url "https://github.com/owenthereal/upterm/archive/refs/tags/v0.25.1.tar.gz"
  sha256 "ad26cd4fd70e182c9cd7ab003b23bb6cb8ccabd9cfda3ae012c9be90901a1b08"
  license "Apache-2.0"
  head "https://github.com/owenthereal/upterm.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "53bd9afb62ce1caf97495a6ef83d4de677737275613a8875a644e14d66334d46"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d65670104e207b8b3f94e00654db3480479a39d4be94abc78e1f967be7632c88"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "99b485d8554f2959d5c5e0eed6532acb861e8ffdd33a781670a25c2baecae2d8"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9127f35d620920c2034d7536ab0312320fbfeafed353469347f09c2ef4a2266f"
    sha256 cellar: :any,                 x86_64_linux:  "ae16689cd24c9db78ce8822ae784c247c19ba07882db8b225819a1714a08d4ec"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -X github.com/owenthereal/upterm/internal/version.Version=#{version}
      -X github.com/owenthereal/upterm/internal/version.Date=#{time.iso8601}
    ]

    %w[upterm uptermd].each do |cmd|
      system "go", "build", *std_go_args(output: bin/cmd, ldflags:), "./cmd/#{cmd}"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/upterm version")
    assert_match version.to_s, shell_output("#{bin}/uptermd version")

    output = shell_output("#{bin}/upterm config view")
    assert_match "# Upterm Configuration File", output
    assert_match "server: ssh://uptermd.upterm.dev:22", output
  end
end
