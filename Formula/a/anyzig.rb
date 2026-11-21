class Anyzig < Formula
  desc "Universal zig executable that runs any version of zig"
  homepage "https://github.com/marler8997/anyzig"
  url "https://github.com/marler8997/anyzig/archive/refs/tags/v2026_11_12.tar.gz"
  sha256 "5403be7549905990e98f036f920536cbf5948008a818cfb1587e408029333133"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:[._]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.filter_map { |tag| tag[regex, 1]&.tr("_", ".") }
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "456cf0176ac59ab9d277c26426455d0b18a1077b6802e7a420855526e32d2dc5"
  end

  keg_only "it conflicts with zig"

  depends_on "zig" => :build

  deny_network_access!

  def fetch
    system "zig", "build", "--fetch=all"
  end

  def install
    # zig-patch preserves the read-only permissions of Homebrew's Zig standard library.
    cp_r formula_opt_lib("zig")/"zig", buildpath/"zig-lib"
    chmod_R "u+w", buildpath/"zig-lib"
    ENV["ZIG_LIB_DIR"] = buildpath/"zig-lib"

    archive_version = version.to_s.tr(".", "_")
    args = %W[-Dforce-version=v#{archive_version}]
    system "zig", "build", *args, *std_zig_args
  end

  test do
    archive_version = version.to_s.tr(".", "_")
    assert_match "v#{archive_version}", shell_output("#{bin}/zig any version").strip
    system bin/"zig", "any", "list-installed"
  end
end
