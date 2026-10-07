class Anchor < Formula
  desc "Solana Program Framework"
  homepage "https://anchor-lang.com"
  url "https://github.com/otter-sec/anchor/archive/refs/tags/v1.2.1.tar.gz"
  sha256 "c346ba9189b0d3e500653fdf7331940b8bca9b2fbf7286c53976b9ac55b8975f"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 sequoia: "0feac195298a515589c990f35b2dcdb6018393b99f50223204be84657e4d1426"
  end

  depends_on "pkgconf" => :build
  depends_on "node" => :test
  depends_on "rust"

  on_linux do
    depends_on "systemd" # for `libudev`
  end

  allow_network_access! :test

  def anchor_workspace_toml
    <<~TOML
      [provider]
      cluster = "localnet"
      wallet = "~/.config/solana/id.json"

      [programs.localnet]
    TOML
  end

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # FIXME: "Unknown attribute kind (102) (Producer: 'LLVM21.1.8' Reader: 'LLVM APPLE_1_1600.0.26.6_0')"
    inreplace "Cargo.toml", "lto = true", "lto = false"

    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "cli", features: "solana-v4")

    # TEMPORARY: anchor searches parents for `Anchor.toml` and the Linux sandbox denies listing `/`
    (buildpath/"Anchor.toml").write anchor_workspace_toml
    generate_completions_from_executable(bin/"anchor", "completions", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/anchor --version")

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
