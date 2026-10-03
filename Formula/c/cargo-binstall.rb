class CargoBinstall < Formula
  desc "Binary installation for rust projects"
  homepage "https://github.com/cargo-bins/cargo-binstall"
  url "https://github.com/cargo-bins/cargo-binstall/archive/refs/tags/v1.25.0.tar.gz"
  sha256 "ab19bb40125d523979e0814bbd0f3f2c72225b29a1db428b4efafb83a84ea573"
  license "GPL-3.0-only"
  head "https://github.com/cargo-bins/cargo-binstall.git", branch: "main"

  # Upstream creates releases that use a stable tag (e.g., `v1.2.3`) but are
  # labeled as "pre-release" on GitHub before the version is released, so it's
  # necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c5114160bebb8f616284badf076c68ddceadfab5065dfa55d36f291d178c8cbf"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "be50ea520fb289b44a5d5be473fdcb4f3a23988417feb35c6cd032ae3863de16"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "83c3a4569c270bdcf163bdadac501858c9de27fdbd22adceef97bfd5cefbe88a"
    sha256 cellar: :any,                 arm64_linux:       "525357e59ed3b64f6e4a2dccccaa9f0263378121846ab5a041bbb461908c13c6"
    sha256 cellar: :any,                 x86_64_linux:      "0635bf2727f9f46e1b77b32d0e86f86b2bbf6ac036fb056c05ddf7829020ba01"
  end

  depends_on "rust" => :build

  # `test do` block resolves a crate from crates.io
  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/bin")
  end

  test do
    ENV["BINSTALL_DISABLE_TELEMETRY"] = "true"

    output = shell_output("#{bin}/cargo-binstall --dry-run radio-sx128x")
    assert_match "resolve: Resolving package: 'radio-sx128x'", output

    assert_equal version.to_s, shell_output("#{bin}/cargo-binstall -V").chomp
  end
end
