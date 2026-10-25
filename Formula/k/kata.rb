class Kata < Formula
  desc "Local-first, federated issue tracker for humans and coding agents"
  homepage "https://katatracker.com"
  url "https://github.com/kenn-io/kata/releases/download/v0.20.0/kata_0.20.0_source.tar.gz"
  sha256 "5647809b6a150f217e14d774499e190e5d6b1d17b1a877fc1028a02585cb0765"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "04264eb70bace0d6f8b9aa9cb3dfd1c1d2ecd53d9595cae06acd22d3374074b4"
  end

  depends_on "go" => :build

  # `test do` block needs network access for `kata init`
  allow_network_access! :test

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -X go.kenn.io/kata/internal/version.Version=v#{version}
      -X go.kenn.io/kata/internal/version.Distribution=homebrew
      -X go.kenn.io/kata/internal/version.BuildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:), "-mod=vendor", "-buildvcs=false", "./cmd/kata"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kata version")

    ENV["KATA_HOME"] = testpath/"kata-home"
    ENV["KATA_TELEMETRY_ENABLED"] = "0"
    begin
      system bin/"kata", "init", "--project", "homebrew-test"
      system bin/"kata", "create", "Homebrew test issue"
      assert_match "Homebrew test issue", shell_output("#{bin}/kata list")
    ensure
      system bin/"kata", "daemon", "stop"
    end
  end
end
