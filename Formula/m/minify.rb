class Minify < Formula
  desc "Minifier for HTML, CSS, JS, JSON, SVG, and XML"
  homepage "https://go.tacodewolff.nl/minify"
  url "https://github.com/tdewolff/minify/archive/refs/tags/v2.24.18.tar.gz"
  sha256 "b23c5014c8c880a9f7592d1abe02091a9ffe84dbdd0b68c75cfcdc8a0405cdc0"
  license "MIT"
  head "https://github.com/tdewolff/minify.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "5982cda23c5886cde9deed123414d5913ee1a0b5576893c849d4fe803e0f4d00"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "5982cda23c5886cde9deed123414d5913ee1a0b5576893c849d4fe803e0f4d00"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "5982cda23c5886cde9deed123414d5913ee1a0b5576893c849d4fe803e0f4d00"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "bf8af328a6187aff523c47231d1699aec78dba5b4e0efdfae80a3f0b32b1c009"
    sha256 cellar: :any,                 x86_64_linux:      "d8893e750630a81d29621e93b8e7e933a20dc07d77d51354e7d9c757ee488b0a"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.Version=#{version}"), "./cmd/minify"
    bash_completion.install "cmd/minify/bash_completion"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/minify --version")

    (testpath/"test.html").write <<~HTML
      <div>
        <div>test1</div>
        <div>test2</div>
      </div>
    HTML
    assert_equal "<div><div>test1</div><div>test2</div></div>", shell_output("#{bin}/minify test.html")
  end
end
