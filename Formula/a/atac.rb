class Atac < Formula
  desc "Simple API client (Postman-like) in your terminal"
  homepage "https://github.com/Julien-cpsn/ATAC"
  url "https://github.com/Julien-cpsn/ATAC/archive/refs/tags/v0.23.1.tar.gz"
  sha256 "af34280a23cf3d8cf1b6d79b35a61bfcaaac661e79358166b05548b5153df53a"
  license "MIT"
  head "https://github.com/Julien-cpsn/ATAC.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "6b853d0423877650b385637bfa84eb0082e09e7d0bfe8561f9825932cbaff5b6"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "oniguruma"

  def install
    ENV["RUSTONIG_DYNAMIC_LIBONIG"] = "1"
    ENV["RUSTONIG_SYSTEM_LIBONIG"] = "1"

    system "cargo", "install", *std_cargo_args

    # stdout is not supported, so install manually
    %w[bash zsh fish powershell].each do |shell|
      system bin/"atac", "completions", shell
    end
    bash_completion.install "atac.bash" => "atac"
    zsh_completion.install "_atac"
    fish_completion.install "atac.fish"
    pwsh_completion.install "_atac.ps1"

    system bin/"atac", "man"
    man1.install "atac.1"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/atac --version")

    system bin/"atac", "collection", "new", "test"
    assert_match "test", shell_output("#{bin}/atac collection list")

    system bin/"atac", "try", "-u", "https://postman-echo.com/post",
                      "-m", "POST", "--duration", "--console", "--hide-content"
  end
end
