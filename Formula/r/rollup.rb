class Rollup < Formula
  desc "Next-generation ES module bundler"
  homepage "https://rollupjs.org/"
  url "https://registry.npmjs.org/rollup/-/rollup-4.65.1.tgz"
  sha256 "dd3ac7c94fad7f8dfcce4798a09f77db6f19e7b5e7d9ad191f2cc733bf33d7fe"
  license all_of: ["ISC", "MIT"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "a50683407c7a336e9149e20481db93ddbcdddf0dcf79cdf7121bd7d03ae7fb35"
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
