class Hut < Formula
  desc "CLI tool for sr.ht"
  homepage "https://sr.ht/~xenrox/hut"
  url "https://git.sr.ht/~xenrox/hut/archive/v0.9.0.tar.gz"
  sha256 "1636cc4b8c983bb55dce25b074b24b9db989b47c2408c6835a6a4849c3ca9563"
  license "AGPL-3.0-or-later"
  head "https://git.sr.ht/~xenrox/hut", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "b016557a5a114cc18a0c6b2feeda3925f3ce76b02d37e14341fae861f53b13fd"
  end

  depends_on "go" => :build
  depends_on "scdoc" => :build

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"config").write <<~EOS
      instance "sr.ht" {
          access-token "some_fake_access_token"
      }
    EOS
    assert_match "gqlclient: server failure: Invalid OAuth bearer token",
      shell_output("#{bin}/hut --config #{testpath}/config todo list 2>&1", 1)
  end
end
