class ProtonPassCli < Formula
  desc "Command-line interface for Proton Pass"
  homepage "https://protonpass.github.io/pass-cli/"
  url "https://github.com/protonpass/pass-cli/archive/refs/tags/2.7.0.tar.gz"
  sha256 "623e6fa0c3d83daa8778e7d6693406f6d5aee82e4b460ddccddb5218322598a4"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "5bc4238280a6de5dcb75968b9dfa04f39c69d8cb2ad03f33beb5e2da76ddee20"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  # Upstream does not currently accept external contributions.
  # Remove `pass-uniffi-bindgen` crate
  patch :DATA

  allow_network_access! :test

  def fetch
    # Regenerate `Cargo.lock` after removing `pass-uniffi-bindgen` member
    system "cargo", "generate-lockfile"
    system "cargo", "fetch", *std_cargo_fetch_args
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
diff --git a/Cargo.toml b/Cargo.toml
index 8be08b9..380a618 100644
--- a/Cargo.toml
+++ b/Cargo.toml
@@ -8,8 +8,6 @@ default-members = [
     "pass-fs",
     "pass",
     "pass-derive",
-    # maturin runs its `uniffi-bindgen` bin (in the default members) to generate the Python bindings
-    "pass-uniffi-bindgen"
 ]
 resolver = "2"
 
