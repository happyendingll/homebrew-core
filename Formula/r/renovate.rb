class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-44.129.0.tgz"
  sha256 "dd20b668b35f08a040fa6b878c3f7027b189dbb0b667ebe7cd08198faba7508c"
  license "AGPL-3.0-only"

  # livecheck needs to surface multiple versions for version throttling but
  # there are thousands of renovate releases on npm. The package page showing
  # versions is several MB in size (and the registry response is 10x that),
  # so curl can time out before the response finishes. This checks releases on
  # GitHub as a workaround, as it provides information on multiple versions
  # but has a much smaller size.
  livecheck do
    url :homepage
    strategy :github_releases
    throttle 10
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "eac385f4c3b816bd5a05bd9774556e28c13802a3b4e21c81b7987fbc45ff0e29"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "eac385f4c3b816bd5a05bd9774556e28c13802a3b4e21c81b7987fbc45ff0e29"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "eac385f4c3b816bd5a05bd9774556e28c13802a3b4e21c81b7987fbc45ff0e29"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "92aa82ec1bf83b137bbb94aac31f5514a64edda4213a146195dfb0f232f23f10"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "92aa82ec1bf83b137bbb94aac31f5514a64edda4213a146195dfb0f232f23f10"
  end

  depends_on "node@24"

  uses_from_macos "git", since: :monterey # needs git >= 2.33.0 (Apple Git-136)

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    # Renovate filters child env vars, so Homebrew's git shim cannot run.
    ENV.remove "PATH", HOMEBREW_SHIMS_PATH/"shared"
    system bin/"renovate", "--platform=local", "--enabled=false"
  end
end
