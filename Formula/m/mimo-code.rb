class MimoCode < Formula
  desc "AI coding agent with cross-session memory"
  homepage "https://github.com/XiaomiMiMo/MiMo-Code"
  url "https://registry.npmjs.org/@mimo-ai/cli/-/cli-0.1.14.tgz"
  sha256 "52061df13851178b9d2a14a70809f77a1dafd03b3b39887413a5976967749b37"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "47be8ae638cfb3f32774bc3e9be0e3f9bb76c3149d9f7bf83300ed0c9ef5e3d1"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args(ignore_scripts: false)
    bin.install_symlink libexec.glob("bin/*")

    # Remove binaries for other architectures, `-musl`, `-baseline`, and `-baseline-musl`
    arch = Hardware::CPU.arm? ? "arm64" : "x64"
    os = OS.linux? ? "linux" : "darwin"
    (libexec/"lib/node_modules/@mimo-ai/cli/node_modules").children.each do |d|
      next unless d.directory?

      rm_r d if d.basename.to_s != "mimocode-#{os}-#{arch}"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mimo --version")
    assert_match "mimo", shell_output("#{bin}/mimo models")
  end
end
