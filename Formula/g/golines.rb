class Golines < Formula
  desc "Golang formatter that fixes long lines"
  homepage "https://github.com/golangci/golines"
  url "https://github.com/golangci/golines/archive/refs/tags/v0.16.0.tar.gz"
  sha256 "5745f0e490033ae8eb2f9d731cd7a6b5efe2a5b71a830a6cb9900f4140c4d322"
  license "MIT"
  head "https://github.com/golangci/golines.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "b9678a537459c3a70355352d5c7a31059ce5261996bce26ef0f4cc25a19f49e5"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X main.version=#{version} -X main.commit=#{tap.user} -X main.date=#{time.iso8601}"
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/golines --version")

    (testpath/"given.go").write <<~GO
      package main

      var strings = []string{"foo", "bar", "baz"}
    GO

    (testpath/"expected.go").write <<~GO
      package main

      var strings = []string{\n\t"foo",\n\t"bar",\n\t"baz",\n}
    GO

    assert_equal (testpath/"expected.go").read, shell_output("#{bin}/golines --max-len=30 given.go")
  end
end
