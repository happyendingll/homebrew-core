class Bend < Formula
  desc "Language that blocks AI mistakes via proof"
  homepage "https://bend-lang.com"
  url "https://github.com/bendlang/bend/archive/refs/tags/v2.0.16.tar.gz"
  sha256 "1c7733dcda658eae77d75a9515002e6ba42c91f95e84db62762fdb39625ed2af"
  license "Apache-2.0"
  head "https://github.com/bendlang/bend.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "c223aad3fe367ad76d0fb71b34e34d3315b492b23297054ef4178cf1fa313f3d"
  end

  depends_on "bun"

  on_linux do
    depends_on "llvm"
  end

  deny_network_access!

  def install
    libexec.install "bend2", "guide"
    (bin/"bend").write_env_script formula_opt_bin("bun")/"bun", libexec/"bend2/main.ts", BEND_NO_TELEMETRY: "1"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bend --version")

    (testpath/"test.bend").write <<~BEND
      import Base

      def main() -> U32:
        (2 + 3 : U32)
    BEND
    assert_equal "5\n", shell_output("#{bin}/bend #{testpath}/test.bend")

    system bin/"bend", testpath/"test.bend", "-o", testpath/"test"
    assert_equal "5\n", shell_output(testpath/"test")
  end
end
