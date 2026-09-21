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
  depends_on "openssl@3"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  service do
    run [opt_bin/"zellij", "web"]
    keep_alive true
    environment_variables PATH: std_service_path_env
    log_path var/"log/zellij.log"
    error_log_path var/"log/zellij.log"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@3")

    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"zellij", "setup", "--generate-completion")
  end

  test do
    assert_match("keybinds", shell_output("#{bin}/zellij setup --dump-config"))
    assert_match("zellij #{version}", shell_output("#{bin}/zellij --version"))
  end
end
