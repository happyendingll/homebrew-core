class Oxfmt < Formula
  desc "High-performance formatting tool for JavaScript and TypeScript"
  homepage "https://oxc.rs/"
  url "https://registry.npmjs.org/oxfmt/-/oxfmt-0.69.0.tgz"
  sha256 "5b562bd445f256ae594196dd5cd14d81df80c3434f2bd7bb93a02848f28916fb"
  license "MIT"

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "be4a5d664d95f3ab26224da98f97c2bbf536b7462e62e965452f0363821924ac"
    sha256 cellar: :any,                 arm64_tahoe:       "be4a5d664d95f3ab26224da98f97c2bbf536b7462e62e965452f0363821924ac"
    sha256 cellar: :any,                 arm64_sequoia:     "be4a5d664d95f3ab26224da98f97c2bbf536b7462e62e965452f0363821924ac"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "853aa616bedc0dae8528816de0eb662382ee66927a6af9f952d2b895c75a2b94"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "3dab285930ec41048a87e6054dcecf6819078b34b50e397595014acc2eac2490"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    (testpath/"test.js").write("const arr = [1,2];")
    system bin/"oxfmt", "test.js"
    assert_equal "const arr = [1, 2];\n", (testpath/"test.js").read
  end
end
