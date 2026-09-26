class Gowall < Formula
  desc "Tool to convert a Wallpaper's color scheme / palette"
  homepage "https://achno.github.io/gowall-docs/"
  url "https://github.com/Achno/gowall/archive/refs/tags/v0.2.4.tar.gz"
  sha256 "df19d8a7f4d138cfa233415ad71250c788aa1a3d310b4b19ca952fb0750c0c36"
  license "MIT"
  revision 6
  head "https://github.com/Achno/gowall.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "680ac66952b078a6a508bd45079b3fb559577c3d4657ae245a1ae5b9a869672b"
  end

  depends_on "go" => :build
  depends_on "mupdf"

  resource "go-fitz" do
    url "https://github.com/gen2brain/go-fitz/archive/refs/tags/v1.24.15.tar.gz"
    sha256 "086b656bbb00c314083b7097b1d295f98034f4d75ffddf4fc706a5f1c3c5cf6b"
  end

  deny_network_access!

  def fetch
    system "go", "mod", "download", "all"
  end

  def install
    # Work around https://github.com/gen2brain/go-fitz/issues/143
    (buildpath/"go-fitz").install resource("go-fitz")
    (buildpath/"go.work").write <<~GOMOD
      go #{Formula["go"].version.major_minor}
      use .
      replace github.com/gen2brain/go-fitz => ./go-fitz
    GOMOD
    inreplace "go-fitz/fitz_cgo.go", "C.int(len(buf))", "C.size_t(len(buf))"

    ENV["CGO_ENABLED"] = "1" # for go-fitz
    # Workaround to avoid patchelf corruption when cgo is required
    if OS.linux? && Hardware::CPU.arm64?
      ENV["GO_EXTLINK_ENABLED"] = "1"
      ENV.append "GOFLAGS", "-buildmode=pie"
    end

    system "go", "build", *std_go_args(tags: "extlib")

    generate_completions_from_executable(bin/"gowall", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gowall --version")

    assert_match "arcdark", shell_output("#{bin}/gowall list")

    system bin/"gowall", "extract", test_fixtures("test.jpg")
  end
end
