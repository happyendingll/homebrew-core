class Jump < Formula
  desc "Helps you navigate your file system faster by learning your habits"
  homepage "https://github.com/gsamokovarov/jump"
  url "https://github.com/gsamokovarov/jump/archive/refs/tags/v0.69.0.tar.gz"
  sha256 "17567f7acd305e2e8093f49e591aa03d74bc5c94204b0461550b0bd8055490af"
  license "MIT"
  head "https://github.com/gsamokovarov/jump.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "ee89d9fea7046cfb90185b3291e64055037e91add76f8a05b5d73a1d910461c3"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args

    generate_completions_from_executable(bin/"jump", "shell")
    man1.install "man/jump.1"
    man1.install "man/j.1"
  end

  test do
    (testpath/"test_dir").mkpath
    ENV["JUMP_HOME"] = testpath.to_s
    system bin/"jump", "chdir", testpath/"test_dir"

    assert_equal (testpath/"test_dir").to_s, shell_output("#{bin}/jump cd tdir").chomp
  end
end
