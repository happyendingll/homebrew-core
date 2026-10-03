class CubejsCli < Formula
  desc "Cube.js command-line interface"
  homepage "https://cube.dev/"
  url "https://registry.npmjs.org/cubejs-cli/-/cubejs-cli-1.7.49.tgz"
  sha256 "ac684f68f0a1576f0a02df5805c6522f677c771d18eecada99738ea5fc37213e"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0727c7f5c2b2b4667072cef3a8a95a806bf2187e72f891d1a15e034628fefab9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "0727c7f5c2b2b4667072cef3a8a95a806bf2187e72f891d1a15e034628fefab9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "0727c7f5c2b2b4667072cef3a8a95a806bf2187e72f891d1a15e034628fefab9"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "e54ae40b7a23b5cd2ac7d2335e08a411f8b57240877f6858253ba684018a43f4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "e54ae40b7a23b5cd2ac7d2335e08a411f8b57240877f6858253ba684018a43f4"
  end

  depends_on "node"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    node_modules = libexec/"lib/node_modules/cubejs-cli/node_modules"
    deuniversalize_machos node_modules/"fsevents/fsevents.node" if OS.mac?
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cubejs --version")
    system bin/"cubejs", "create", "hello-world", "-d", "postgres"
    assert_path_exists testpath/"hello-world/model/cubes/orders.yml"
  end
end
