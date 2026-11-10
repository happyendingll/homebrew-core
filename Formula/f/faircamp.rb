class Faircamp < Formula
  desc "Static site generator for audio producers"
  homepage "https://codeberg.org/simonrepp/faircamp"
  url "https://codeberg.org/simonrepp/faircamp/archive/2.0.2.tar.gz"
  sha256 "97046d78d8c09837067ae9290fe7aecf5dbb3eb107c1346583534fcb715349f0"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "5e10f40f3d8f79c4065a5bdebe9f9680ae555a923565ac6036bd4540dc6e1c55"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "ffmpeg"
  depends_on "opus"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # `audiopus_sys` links opus statically on macOS by default
    ENV.append_to_rustflags Utils.safe_popen_read("pkgconf", "--libs", "opus").chomp

    system "cargo", "install", *std_cargo_args(path: "cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/faircamp-cli --version")

    site_dir = testpath/"site"
    release_dir = site_dir/"release"
    release_dir.mkpath
    cp test_fixtures("test.wav"), release_dir/"track.wav"
    cp test_fixtures("test.jpg"), release_dir/"cover.jpg"

    build_dir = testpath/"build"
    system bin/"faircamp-cli", "build", "--site-dir", site_dir, "--build-dir", build_dir
    assert_path_exists build_dir/"index.html"
    assert_path_exists build_dir/"favicon.svg"
  end
end
