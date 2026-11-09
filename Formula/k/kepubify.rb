class Kepubify < Formula
  desc "Convert ebooks from epub to kepub"
  homepage "https://pgaskin.net/kepubify/"
  url "https://github.com/pgaskin/kepubify/archive/refs/tags/v5.0.0.tar.gz"
  sha256 "bd8053d3927440a9bd54022bbda697b937ab0365e55ad70b73c998233e57c030"
  license "MIT"
  head "https://github.com/pgaskin/kepubify.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(:?\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "5c7e8b877568c8c547374b42d11ee08da134605f94884e0d5f79d59943029525"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/pgaskin/kepubify/v#{version.major}/internal/version.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/kepubify #{pdf} 2>&1", 1)
    assert_match "Error: invalid extension", output

    system bin/"kepubify", test_fixtures("test.epub")
    assert_path_exists testpath/"test_converted.kepub.epub"
  end
end
