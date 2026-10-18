class Rollup < Formula
  desc "Next-generation ES module bundler"
  homepage "https://rollupjs.org/"
  url "https://registry.npmjs.org/rollup/-/rollup-4.64.8.tgz"
  sha256 "fe1bbb60770b447cabb486e2053e29094aaade8d820a6f8530a4e1cb225e435f"
  license all_of: ["ISC", "MIT"]

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "c73f06e370033b3b7e4e861a411231f370cc5ac944b3f74b295951f1249bbca4"
    sha256 cellar: :any,                 arm64_tahoe:       "c73f06e370033b3b7e4e861a411231f370cc5ac944b3f74b295951f1249bbca4"
    sha256 cellar: :any,                 arm64_sequoia:     "c73f06e370033b3b7e4e861a411231f370cc5ac944b3f74b295951f1249bbca4"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "468ea21fdfab4670b8e2f528a1abbf676d2f065ed46899c7f5ee7715a5290611"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "f92eca9d36fd05d006df7d364e585cc88629a76d15373e80387832980641a96f"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    # Replace universal binaries with their native slices
    node_modules = libexec/"lib/node_modules/rollup/node_modules"
    deuniversalize_machos node_modules/"fsevents/fsevents.node"
  end

  test do
    (testpath/"test/main.js").write <<~JS
      import foo from './foo.js';
      export default function () {
        console.log(foo);
      }
    JS

    (testpath/"test/foo.js").write <<~JS
      export default 'hello world!';
    JS

    expected = <<~JS
      'use strict';

      var foo = 'hello world!';

      function main () {
        console.log(foo);
      }

      module.exports = main;
    JS

    assert_equal expected, shell_output("#{bin}/rollup #{testpath}/test/main.js -f cjs")
  end
end
