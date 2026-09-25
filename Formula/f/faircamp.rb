class Faircamp < Formula
  desc "Static site generator for audio producers"
  homepage "https://codeberg.org/simonrepp/faircamp"
  url "https://codeberg.org/simonrepp/faircamp/archive/2.0.0.tar.gz"
  sha256 "b0601a411fe041baae4da86bab4242fc964df6229ff2335955f1d5df46f2deff"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "78af423ea1694207820d06ecba89485b7e27f69547373b0319ccc2dfebb5eeab"
  end

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

    # TODO: drop backward compatibility symlink for the pre-2.0 `faircamp` CLI name
    bin.install_symlink "faircamp-cli" => "faircamp"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/faircamp --version")

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
