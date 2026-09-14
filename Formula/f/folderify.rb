class Folderify < Formula
  desc "Generate pixel-perfect macOS folder icons in the native style"
  homepage "https://github.com/lgarron/folderify"
  url "https://github.com/lgarron/folderify/archive/refs/tags/v4.1.3.tar.gz"
  sha256 "3a50b66b888754047931969d9a1fb84178406b638c183a387a58deb48529776a"
  license "MIT"
  head "https://github.com/lgarron/folderify.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "d71a733f63067e6f6ed82264e3f115edabd91f8f4d8fd961ddfeb717abd71d07"
  end

  depends_on "rust" => :build
  depends_on "imagemagick"
  depends_on :macos

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"folderify", "--completions")
  end

  test do
    # Write an example icon to a file.
    (testpath/"test.svg").write <<~EOS
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
        <circle cx="50" cy="50" r="40" fill="transparent" stroke="black" stroke-width="20" />
      </svg>
    EOS

    # Stop at the iconset: `iconutil` needs LaunchServices, which the sandbox denies
    system bin/"folderify", "test.svg", "--output-iconset", testpath/"test.iconset", "--no-progress"
    assert_predicate testpath/"test.iconset/icon_512x512.png", :size?
  end
end
