class Anchor < Formula
  desc "Solana Program Framework"
  homepage "https://anchor-lang.com"
  url "https://github.com/otter-sec/anchor/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "2b08bcb9b0dabb3ca4dfb24cd865f255fc7b5519d0b5c41063b8a8b89e16d58c"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "24f011870ded4c83db95a508b97234ea556e6fe5b023c05b5c53e95fd7d9130a"
  end

  depends_on "pkgconf" => :build
  depends_on "node" => :test
  depends_on "rust"

  on_linux do
    depends_on "systemd" # for `libudev`
  end

  def anchor_workspace_toml
    <<~TOML
      [provider]
      cluster = "localnet"
      wallet = "~/.config/solana/id.json"

      [programs.localnet]
    TOML
  end

  def install
    # FIXME: "Unknown attribute kind (102) (Producer: 'LLVM21.1.8' Reader: 'LLVM APPLE_1_1600.0.26.6_0')"
    inreplace "Cargo.toml", "lto = true", "lto = false"

    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "cli")

    # TEMPORARY: anchor searches parents for `Anchor.toml` and the Linux sandbox denies listing `/`
    (buildpath/"Anchor.toml").write anchor_workspace_toml
    generate_completions_from_executable(bin/"anchor", "completions", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match "anchor-cli #{version}", shell_output("#{bin}/anchor --version")

    (testpath/"Anchor.toml").write anchor_workspace_toml
    (testpath/"Cargo.toml").write <<~TOML
      [workspace]
      members = []
      resolver = "2"
    TOML

    system bin/"anchor", "init", "--force", "test_project"
    assert_path_exists testpath/"test_project/Cargo.toml"
    assert_path_exists testpath/"test_project/Anchor.toml"
  end
end
