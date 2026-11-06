class Golines < Formula
  desc "Golang formatter that fixes long lines"
  homepage "https://github.com/golangci/golines"
  url "https://github.com/golangci/golines/archive/refs/tags/v0.16.1.tar.gz"
  sha256 "8cc653d7451b526edcc61b6dd51e7ac07815f6ba93c99a350495d97e02661ae0"
  license "MIT"
  head "https://github.com/golangci/golines.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "60b37c5240c62e2d28aa1163a495748b206c5adaad233ca4627bc0ec1a3c65d4"
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
