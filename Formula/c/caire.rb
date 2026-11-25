class Caire < Formula
  desc "Content aware image resize tool"
  homepage "https://github.com/esimov/caire"
  url "https://github.com/esimov/caire/archive/refs/tags/v1.6.1.tar.gz"
  sha256 "caad6520cc42a17216d5cd95f18cb778d42844468cfb1405e5bee71d36f023c6"
  license "MIT"
  head "https://github.com/esimov/caire.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "d92d26137b1a4834e39371ee962ead998bab2843731dfded6e59c4b7c70a4522"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "vulkan-headers" => :build
    depends_on "libx11"
    depends_on "libxcursor"
    depends_on "libxfixes"
    depends_on "libxkbcommon"
    depends_on "mesa"
    depends_on "wayland"
  end

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Workaround to avoid patchelf corruption when cgo is required (for gioui.org/internal/vk)
    if OS.linux? && Hardware::CPU.arm64?
      ENV["CGO_ENABLED"] = "1"
      ENV["GO_EXTLINK_ENABLED"] = "1"
      ENV.append "GOFLAGS", "-buildmode=pie"
    end

    system "go", "build", *std_go_args(ldflags: "-X main.Version=#{version}"), "./cmd/caire"
  end

  test do
    system bin/"caire", "-in", test_fixtures("test.png"), "-out", testpath/"test_out.png",
                        "-width=1", "-height=1", "-perc=1", "-preview=false"
    assert_path_exists testpath/"test_out.png"
    assert_match version.to_s, shell_output("#{bin}/caire -help 2>&1")
  end
end
