class Lsr < Formula
  desc "Ls but with io_uring"
  homepage "https://tangled.org/rockorager.dev/lsr"
  license "MIT"
  revision 1
  head "https://tangled.org/rockorager.dev/lsr.git", branch: "main"

  stable do
    url "https://tangled.org/rockorager.dev/lsr/archive/refs%2Ftags%2Fv1.0.0.tar.gz"
    sha256 "9b54dd8b5ca3f3f61605d6bcf900137c369e01d49454e543dd3b57805b52c55e"

    # Backport to build with Zig 0.15
    patch do
      url "https://tangled.org/rockorager.dev/lsr/commit/1079dbd7fb3fc38fad127d3e5f9bc51e088762be.diff"
      sha256 "1a6ac416cef6b467dc19f0e859b0f1705dac41b4406db6f3539ed0650788390f"
      type :backport
    end
    patch do
      file "Patches/lsr/zig-0.15.diff"
      type :backport # https://tangled.org/rockorager.dev/lsr/commit/a9cfda7e53715538fe355622205d63d9efccde49.diff
    end
  end

  # TODO: remove if releases catch up to recent Zig
  livecheck do
    url :head
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "e63d3abd17b48ad6902b896e74e1898ba51006c6ae84ef417819f1b47d5a2a10"
  end

  # Aligned to `zig@0.15` formula. Can be removed if upstream updates to newer Zig.
  deprecate! date: "2027-04-15", because: "does not build with Zig >= 0.15"
  disable! date: "2028-04-15", because: "does not build with Zig >= 0.15"

  depends_on "zig@0.15" => :build

  deny_network_access!

  def fetch
    system "zig", "build", "--fetch"
  end

  def install
    system "zig", "build", *std_zig_args(release_mode: :small)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lsr --version")

    touch "test.txt"
    if OS.linux?
      # sudo required
      assert_match "error: PermissionDenied", shell_output("#{bin}/lsr 2>&1", 1)
    else
      assert_match "test.txt", shell_output(bin/"lsr")
    end
  end
end
