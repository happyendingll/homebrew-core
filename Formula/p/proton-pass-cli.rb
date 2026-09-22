class ProtonPassCli < Formula
  desc "Command-line interface for Proton Pass"
  homepage "https://protonpass.github.io/pass-cli/"
  url "https://github.com/protonpass/pass-cli/archive/refs/tags/2.4.1.tar.gz"
  sha256 "0fa81f9d7dc494383dff91d6854095dfdde61a76ae63d200a5b71d9e9ba66ef9"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "6908b362cb270ecfa7ccd3f2d222959f55a40e008edda06013b874a468d43d3a"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  # Upstream does not currently accept external contributions.
  # Increase the recursion limit required to compile pass-cli 2.3.3.
  patch :DATA

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "pass-cli")
    generate_completions_from_executable(bin/"pass-cli", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pass-cli --version")
    assert_match "Successful", shell_output("#{bin}/pass-cli logout --force")

    # Most operations require an authenticated session or keyring access.
    ENV["PROTON_PASS_KEY_PROVIDER"] = "fs"
    output_log = testpath/"output.log"
    pid = spawn bin/"pass-cli", "login", [:out, :err] => output_log.to_s
    sleep 5
    assert_match "Waiting for authentication to complete", output_log.read
  ensure
    if pid
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end

__END__
diff --git a/pass-cli/src/main.rs b/pass-cli/src/main.rs
index 43cff31..55c8597 100644
--- a/pass-cli/src/main.rs
+++ b/pass-cli/src/main.rs
@@ -1,3 +1,4 @@
+#![recursion_limit = "256"]
 /*
  *  Copyright (c) 2026 Proton AG
  *  This file is part of Proton AG and Proton Pass.
