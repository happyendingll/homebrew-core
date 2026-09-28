class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-44.116.0.tgz"
  sha256 "08558311553de5e04cc96674e767f76760d8bfb265132f9b8a84a7bdf94a39ef"
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
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "2a81a27ec884152ffdc53e21ce901beecd74881e85fc7c76e77f69f5cf03f135"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "2a81a27ec884152ffdc53e21ce901beecd74881e85fc7c76e77f69f5cf03f135"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "2a81a27ec884152ffdc53e21ce901beecd74881e85fc7c76e77f69f5cf03f135"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "38ce63b92199448743e881ece5a3ffd2863c9fe811803ad982ce8e5538f024d8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "38ce63b92199448743e881ece5a3ffd2863c9fe811803ad982ce8e5538f024d8"
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
