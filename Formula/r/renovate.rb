class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-44.119.0.tgz"
  sha256 "cde4018e27681d010add059d9cd1e96aa6ae5cadccec2170911795ee143bff1d"
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
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "a6935074d08d93fc839b341e413c3fb6a74aabda08ef1828abf70da7909b8b2c"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a6935074d08d93fc839b341e413c3fb6a74aabda08ef1828abf70da7909b8b2c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "a6935074d08d93fc839b341e413c3fb6a74aabda08ef1828abf70da7909b8b2c"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "d19ffde6d0e0ab706c6400e5684e3591ef59238c716b688e654b6aa6cf0b30ab"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "d19ffde6d0e0ab706c6400e5684e3591ef59238c716b688e654b6aa6cf0b30ab"
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
