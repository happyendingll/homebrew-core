class Zellij < Formula
  desc "Pluggable terminal workspace, with terminal multiplexer as the base feature"
  homepage "https://zellij.dev"
  url "https://github.com/zellij-org/zellij/archive/refs/tags/v0.45.1.tar.gz"
  sha256 "5cbe711437d2a61afd9287165f6aca0bcccb9ab1473633665a5b11ed55467852"
  license "MIT"
  head "https://github.com/zellij-org/zellij.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "49cf2414753844333ee24c460086ca13cdca97f5d98d8fe8116eed019334a2b2"
  end

  depends_on "rust" => :build

  uses_from_macos "curl"

  on_linux do
    depends_on "openssl@4" => :build
    depends_on "pkgconf" => :build
  end

  # Updates for yanked chacha20 and minimum openssl-sys to use OpenSSL 4
  patch :DATA

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4") if OS.linux?

    # Remove vendored_curl from default features
    features = ["plugins_from_target", "web_server_capability"]
    features << "window" if build.head?
    odie "Add window feature which is included in default features!" if build.stable? && version >= "0.46.0"

    system "cargo", "install", "--no-default-features", *std_cargo_args(features:)

    generate_completions_from_executable(bin/"zellij", "setup", "--generate-completion")
  end

  service do
    run [opt_bin/"zellij", "web"]
    keep_alive true
    environment_variables PATH: std_service_path_env
    log_path var/"log/zellij.log"
    error_log_path var/"log/zellij.log"
  end

  test do
    assert_match("keybinds", shell_output("#{bin}/zellij setup --dump-config"))
    assert_match("zellij #{version}", shell_output("#{bin}/zellij --version"))
  end
end

__END__
diff --git a/Cargo.lock b/Cargo.lock
index 592e22320..72c51a0f0 100644
--- a/Cargo.lock
+++ b/Cargo.lock
@@ -698,9 +698,9 @@ dependencies = [
 
 [[package]]
 name = "chacha20"
-version = "0.10.1"
+version = "0.10.2"
 source = "registry+https://github.com/rust-lang/crates.io-index"
-checksum = "d524456ba66e72eb8b115ff89e01e497f8e6d11d78b70b1aa13c0fbd97540a81"
+checksum = "65c35e4b699c7e15ccbe7ee35c005e4fc0a278d22238a2857e6ce2dadeda1b06"
 dependencies = [
  "cfg-if",
  "cpufeatures 0.3.0",
@@ -3354,9 +3354,9 @@ dependencies = [
 
 [[package]]
 name = "openssl-sys"
-version = "0.9.111"
+version = "0.9.114"
 source = "registry+https://github.com/rust-lang/crates.io-index"
-checksum = "82cab2d520aa75e3c58898289429321eb788c3106963d0dc886ec7a5f4adc321"
+checksum = "13ce1245cd07fcc4cfdb438f7507b0c7e4f3849a69fd84d52374c66d83741bb6"
 dependencies = [
  "cc",
  "libc",
