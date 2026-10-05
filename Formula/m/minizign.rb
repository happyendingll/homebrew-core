class Minizign < Formula
  desc "Minisign reimplemented in Zig"
  homepage "https://github.com/jedisct1/zig-minisign"
  url "https://github.com/jedisct1/zig-minisign/archive/refs/tags/0.1.14.tar.gz"
  sha256 "cda224ceb7d6adb25b99f313f89212e4f6272f41108c1e6eb2a6ea2a05cedc34"
  license "ISC"
  head "https://github.com/jedisct1/zig-minisign.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "8f5531997ac88665c2d797dd808ffbab2a8c0d74e6c2e56cca9653401caf101c"
  end

  depends_on "zig" => :build

  deny_network_access!

  def fetch
    system "zig", "build", "--fetch"
  end

  def install
    system "zig", "build", *std_zig_args
  end

  test do
    # Generate a test key pair with an empty password
    pipe_output("#{bin}/minizign -G -s #{testpath}/test.key -p #{testpath}/test.pub", "\n", 0)
    assert_path_exists testpath/"test.key"
    assert_path_exists testpath/"test.pub"

    # Create a test file and sign it
    (testpath/"test.txt").write "Out of the mountain of despair, a stone of hope."
    system bin/"minizign", "-S", "-s", "test.key", "-m", "test.txt"
    assert_path_exists testpath/"test.txt.minisig"

    # Verify the signature
    system bin/"minizign", "-V", "-p", "test.pub", "-m", "test.txt"
  end
end
