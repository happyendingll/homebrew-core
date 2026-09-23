class Oxfmt < Formula
  desc "High-performance formatting tool for JavaScript and TypeScript"
  homepage "https://oxc.rs/"
  url "https://registry.npmjs.org/oxfmt/-/oxfmt-0.70.0.tgz"
  sha256 "cb6b759f6333166533bb7c383f829a8579e7f0e2fb21ff36e6e44d019c8c38b4"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "6ef2708746f625afe52394ff790c8b2388785a9ffd5059a090dbda644169d5bf"
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
