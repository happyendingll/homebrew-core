class Rustnet < Formula
  desc "Cross-platform network monitoring terminal UI with deep packet inspection"
  homepage "https://github.com/domcyrus/rustnet"
  url "https://github.com/domcyrus/rustnet/archive/refs/tags/v1.7.0.tar.gz"
  sha256 "9d3f6509da06f832c04c5accc7b777c18f3de8b32c885137c9a1346990694dda"
  license "Apache-2.0"
  head "https://github.com/domcyrus/rustnet.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "fa654c3a34716c7a7364eb623eb409483b8c1e9dc1df44f95c0f602093fa958d"
  end

  depends_on "rust" => :build

  uses_from_macos "libpcap"

  on_linux do
    depends_on "llvm" => :build
    depends_on "pkgconf" => :build
    depends_on "elfutils"
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["RUSTNET_ASSET_DIR"] = buildpath/"assets-generated"
    (buildpath/"assets-generated").mkpath

    if OS.linux?
      # Homebrew's compiler shim rewrites `clang` invocations to `gcc`, which
      # breaks libbpf-cargo's BPF compile step (it runs `clang -target bpf`,
      # an option gcc rejects). Surface the real clang from llvm in a shim
      # dir that we place first on PATH; regular C compiles still go through
      # Homebrew's gcc as intended.
      (buildpath/"bpf-clang").mkpath
      (buildpath/"bpf-clang"/"clang").make_symlink formula_opt_bin("llvm")/"clang"
      ENV.prepend_path "PATH", buildpath/"bpf-clang"
    end

    system "cargo", "install", *std_cargo_args

    asset_dir = buildpath/"assets-generated"
    bash_completion.install asset_dir/"rustnet.bash" => "rustnet"
    zsh_completion.install asset_dir/"_rustnet"
    fish_completion.install asset_dir/"rustnet.fish"
    man1.install asset_dir/"rustnet.1"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rustnet --version")

    output = shell_output("#{bin}/rustnet --headless --log-level not-a-level 2>&1", 1)
    assert_match "Invalid log level", output
  end
end
