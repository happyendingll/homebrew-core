class Apkeep < Formula
  desc "Command-line tool for downloading APK files from various sources"
  homepage "https://github.com/EFForg/apkeep"
  url "https://github.com/EFForg/apkeep/archive/refs/tags/1.1.0.tar.gz"
  sha256 "20407a9420cb2a47a8801d744a8ebeefff5d0cc62c5a956445724fb5cde5897c"
  license "MIT"
  head "https://github.com/EFForg/apkeep.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "04602a073421d85335dbe06e59a6121c948d47f21f82acacfd8f9cfe10cd528c"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/apkeep --version")

    # hello world apk, https://play.google.com/store/apps/details?id=dev.egl.com.holamundo&hl=en_US
    system bin/"apkeep", "--download-source", "apk-pure", "--options", "acknowledge_dangers=true",
           "--app", "dev.egl.com.holamundo", testpath
    assert_path_exists "dev.egl.com.holamundo.xapk"
  end
end
