class LeappCli < Formula
  desc "Cloud credentials manager cli"
  homepage "https://www.leapp.cloud/"
  url "https://registry.npmjs.org/@noovolari/leapp-cli/-/leapp-cli-0.1.65.tgz"
  sha256 "a770256e2ce62f08c17650a30e785e46f92e7acb03e2bcbdec949054467b711c"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "7f26fae512534cbccca6cda6fdd7c387016c0ef1acfa4a82dc5924bfdbdafcce"
  end

  depends_on "pkgconf" => :build
  depends_on "node"

  uses_from_macos "python" => :build

  on_linux do
    depends_on "python-setuptools" => :build
    depends_on "glib"
    depends_on "libsecret"
  end

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    # Build keytar's native addon explicitly
    cd libexec/"lib/node_modules/@noovolari/leapp-cli/node_modules/keytar" do
      system "npm", "run", "build"
    end
  end

  def caveats
    on_macos do
      <<~EOS
        Only the `leap` CLI is installed. For Leapp.app:
          brew install --cask leapp
      EOS
    end
  end

  test do
    assert_match "Leapp app must be running to use this CLI",
      shell_output("#{bin}/leapp idp-url create --idpUrl https://example.com 2>&1", 2).strip
  end
end
