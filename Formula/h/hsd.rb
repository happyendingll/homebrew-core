class Hsd < Formula
  desc "Handshake Daemon & Full Node"
  homepage "https://handshake.org"
  url "https://github.com/handshake-org/hsd/archive/refs/tags/v8.0.0.tar.gz"
  sha256 "1de0ebbbac6ca35d62353227176c7377203a82efbc27fdf08ad23dedb481ee28"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "ef0c0eb748d238e5db08d2acc804f304e5d5cd710021f809b74fde525725f7d9"
  end

  depends_on "node"
  depends_on "unbound"

  on_sonoma :or_older do
    depends_on "gmp"
  end

  def install
    system "npm", "install", *std_npm_args(ignore_scripts: false)
    bin.install_symlink Dir[libexec/"bin/*"]
  end

  test do
    (testpath/"script.js").write <<~JS
      const assert = require('assert');
      const hsd = require('#{libexec}/lib/node_modules/hsd');
      assert(hsd);

      const node = new hsd.FullNode({
        prefix: '#{testpath}/.hsd',
        memory: false
      });
      (async () => {
        await node.ensure();
      })();
    JS
    system formula_opt_bin("node")/"node", testpath/"script.js"
    assert_predicate testpath/".hsd", :directory?
  end
end
