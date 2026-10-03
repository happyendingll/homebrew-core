class Kingfisher < Formula
  desc "MongoDB's blazingly fast secret scanning and validation tool"
  homepage "https://mongodb.github.io/kingfisher/"
  url "https://github.com/mongodb/kingfisher/archive/refs/tags/v2.9.1.tar.gz"
  sha256 "119248ac27b90ac4c39f404905cb74e7c36f044bbd1510cd52bc62415960d91e"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "0db617d294ecb61d43ae6b323726bc6163e2c98216154a09bb16d4978ac8bf5b"
    sha256 cellar: :any, arm64_tahoe:       "930702a1fe0eccb1bd0726b9f20531b75b0be8f503706b1d498d31209bb309a5"
    sha256 cellar: :any, arm64_sequoia:     "f090a4e47a37d913fef3bdad7b00b019fb535f07b1be59cfe9b9e21e9e21e7d7"
    sha256 cellar: :any, arm64_linux:       "5aefc6918f2f8802e47a6970e41a608a9f18f2c58ec37297e6f8e75c61464a1b"
    sha256 cellar: :any, x86_64_linux:      "a1043e73aeedcb44c3f47f614bbdda0f0e7b27995d2871dff2759cee86591a65"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "vectorscan" => :build # kingfisher-vectorscan uses static library
  depends_on "aws-lc"

  uses_from_macos "sqlite"

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["AWS_LC_SYS_USE_SYSTEM"] = "1"
    ENV["HYPERSCAN_ROOT"] = formula_opt_prefix("vectorscan")
    ENV["LIBSQLITE3_SYS_USE_PKG_CONFIG"] = "1"

    args = ["--features=system-alloc"] if OS.mac?
    system "cargo", "install", *args, *std_cargo_args
  end

  test do
    output = shell_output("#{bin}/kingfisher scan --git-url https://github.com/homebrew/.github")
    assert_match "|Findings....................: 0", output
  end
end
