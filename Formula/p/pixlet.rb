class Pixlet < Formula
  desc "App runtime and UX toolkit for pixel-based apps"
  homepage "https://github.com/tronbyt/pixlet"
  url "https://github.com/tronbyt/pixlet/archive/refs/tags/v0.54.0.tar.gz"
  sha256 "30466e15586dfc93f2bc049ddaa3a3df51df37b750476eb3b2a68565362ea4e9"
  license "Apache-2.0"
  head "https://github.com/tronbyt/pixlet.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "e6c6ddfea9cd75896559ca48a6af111aed3b6c70fa14280539f890bb3c21ceef"
  end

  depends_on "go" => :build
  depends_on "node" => :build
  depends_on "webp"

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    cd "frontend" do
      system "npm", "install", *std_npm_args(prefix: false)
      system "npm", "run", "build"
    end

    ldflags = "-X github.com/tronbyt/pixlet/runtime.Version=v#{version}"
    system "go", "build", *std_go_args(ldflags:, tags: "gzip_fonts")

    generate_completions_from_executable(bin/"pixlet", shell_parameter_format: :cobra)
  end

  test do
    (testpath/"hello.star").write <<~EOS
      load("render.star", "render")
      def main():
        return render.Root(child=render.Text("hello"))
    EOS
    system bin/"pixlet", "render", "hello.star", "-o", "out.webp"
    assert_path_exists testpath/"out.webp"
  end
end
