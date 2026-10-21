class Iamb < Formula
  desc "Matrix client for Vim addicts"
  homepage "https://iamb.chat"
  url "https://github.com/ulyssa/iamb/archive/refs/tags/v0.0.13.tar.gz"
  sha256 "a87b81d4cd60f72725b5b633c78ecb28fccc457f6319037fa9d12096fd6e3ef1"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0e4349b4008d41c4e2fbf3519e3a9994812e6a7c91ae2aa03087877cff250fb6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c471970b020fbe6191d45469cf97cd53a28618fc7e99aaca3c69ab2ab6e97753"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "a6552296afd21810d3fe8dad89d410314d6312dcf4b8625a5985919d5930c228"
    sha256 cellar: :any,                 arm64_linux:       "ae3326d2987b976bb8e16ef6347a359dcb5eef491719a6bac2b2ae229ec1fc0e"
    sha256 cellar: :any,                 x86_64_linux:      "6b82e2c45518f3e432ce29f0cbeae10dc3286ddaae6b7b19f82e3b95df0c6ea1"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "sqlite", since: :ventura # requires sqlite3_error_offset

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["LIBSQLITE3_SYS_USE_PKG_CONFIG"] = "1"
    ENV["VERGEN_GIT_SHA"] = tap.user
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "Please create a configuration file", shell_output(bin/"iamb", 2)
  end
end
