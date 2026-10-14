class CodeCli < Formula
  desc "Command-line interface built-in Visual Studio Code"
  homepage "https://code.visualstudio.com"
  url "https://github.com/microsoft/vscode/archive/refs/tags/1.141.2.tar.gz"
  sha256 "56ffe39b8d0daa09b4b46c1725a5e2de29a79ebe9b2608bbf59396feeae4f70f"
  license "MIT"
  head "https://github.com/microsoft/vscode.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "a8b2cddcc87a3feb922272eec0d8492fe54360616dc9a0e120613a420ed45132"
    sha256 cellar: :any, arm64_tahoe:       "caa024b263f1cb06a0df3f58318150f09f3518f709a222a86e18f8f1a95b2a44"
    sha256 cellar: :any, arm64_sequoia:     "1e56957b3ab4e450644b68dcf651476bfb8b69e63059450a889dfbc3671611d5"
    sha256 cellar: :any, arm64_linux:       "160ae860fdc5086793b59abaf23c9fa2f48b9d16ffd25f6b8d2789afe6587198"
    sha256 cellar: :any, x86_64_linux:      "cdf3c1a0cfeea54bbdff2c652a326f10aca01bd6398c5f24a781b133c5d70c6a"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def openssl = Formula["openssl@4"]

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    # https://crates.io/crates/openssl#manual-configuration
    ENV["OPENSSL_DIR"] = openssl.opt_prefix

    ENV["VSCODE_CLI_NAME_LONG"] = "Code OSS"

    cd "cli" do
      system "cargo", "install", *std_cargo_args
    end
  end

  test do
    require "utils/linkage"

    assert_match "Successfully removed all unused servers",
      shell_output("#{bin}/code tunnel prune")
    assert_match version.to_s, shell_output("#{bin}/code --version")

    linked_libraries = [
      openssl.opt_lib/shared_library("libssl"),
      openssl.opt_lib/shared_library("libcrypto"),
    ]

    linked_libraries.each do |library|
      assert Utils.binary_linked_to_library?(bin/"code", library),
             "No linkage with #{library.basename}! Cargo is likely using a vendored version."
    end
  end
end
