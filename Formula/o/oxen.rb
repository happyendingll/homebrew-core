class Oxen < Formula
  desc "Data VCS for structured and unstructured machine learning datasets"
  homepage "https://www.oxen.ai/", browsed: "2026-10-12"
  url "https://github.com/Oxen-AI/Oxen/archive/refs/tags/v0.68.0.tar.gz"
  sha256 "5d2fffe31016e474a8afd94951b6b4e2fc7ab4d14c07ce76d35209a7b623162c"
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
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "2aceef4846b9ac9e45a7338f444f6299132a8ba23d36fda2790ddec76c055df5"
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
