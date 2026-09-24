class Oxen < Formula
  desc "Data VCS for structured and unstructured machine learning datasets"
  homepage "https://www.oxen.ai/"
  url "https://github.com/Oxen-AI/Oxen/archive/refs/tags/v0.58.0.tar.gz"
  sha256 "7f02ddd9e813bab42ea7fe84887c9787a3fbd695bf2065ab907f04d2e2c3366c"
  license "Apache-2.0"
  head "https://github.com/Oxen-AI/Oxen.git", branch: "main"

  # The upstream repository contains tags that are not releases.
  # Limit the regex to only match version numbers.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest
  end

  no_autobump! because: :bumped_by_upstream

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "101e8613ca7c00e13e4144634f47431584ffccd00f147dd65cb3c417918bcbd7"
    sha256 cellar: :any, arm64_tahoe:       "4cec028b9346779274d1cb865623f8ad504cc43ab56e79440bab792be1c050a5"
    sha256 cellar: :any, arm64_sequoia:     "ed4cd45a1d203df568beee581f38a9e33db829e73a8b0a96a5f49cd934b43ae0"
    sha256 cellar: :any, arm64_linux:       "dd3ea193e225980be5021d0d810bc9ab03491f8374ed56894076bdf05a61f513"
    sha256 cellar: :any, x86_64_linux:      "0a2a57aef62d43a20c39a37484641df1577b1c7ce88fed47583e22032f7d4857"
  end

  depends_on "cmake" => :build # for libz-ng-sys
  depends_on "rust" => :build
  depends_on "rocksdb"

  uses_from_macos "llvm" => :build # for libclang

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["ROCKSDB_LIB_DIR"] = formula_opt_lib("rocksdb")
    system "cargo", "install", *std_cargo_args(path: "crates/oxen-cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/oxen --version")

    system bin/"oxen", "init"
    assert_match "default_host = \"hub.oxen.ai\"", (testpath/".config/oxen/auth_config.toml").read
  end
end
