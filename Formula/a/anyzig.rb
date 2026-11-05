class Anyzig < Formula
  desc "Universal zig executable that runs any version of zig"
  homepage "https://github.com/marler8997/anyzig"
  url "https://github.com/marler8997/anyzig/archive/refs/tags/v2026_11_03.tar.gz"
  sha256 "487939d1b2f81b08477ba133a706a0194e67f9a27ef7ed97451b02c9cdf31dc2"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:[._]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.filter_map { |tag| tag[regex, 1]&.tr("_", ".") }
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "cfdc79b5494343ec0e519b9feef447e1fce7181c82831fb52fea732712a92a14"
  end

  keg_only "it conflicts with zig"

  depends_on "zig" => :build

  deny_network_access!

  def fetch
    system "zig", "build", "--fetch"
  end

  def install
    args = %W[-Dforce-version=v#{version.to_s.tr(".", "_")}]
    system "zig", "build", *args, *std_zig_args
  end

  test do
    assert_match "v#{version.to_s.tr(".", "_")}", shell_output("#{bin}/zig any version").strip
    system bin/"zig", "any", "list-installed"
  end
end
