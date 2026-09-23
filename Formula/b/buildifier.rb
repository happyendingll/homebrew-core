class Buildifier < Formula
  desc "Format bazel BUILD files with a standard convention"
  homepage "https://github.com/bazelbuild/buildtools"
  url "https://github.com/bazelbuild/buildtools/archive/refs/tags/v10.1.0.tar.gz"
  sha256 "fa0b905032d49a621679e7318875736e451895a1417d992fbbebd27f82b83c38"
  license "Apache-2.0"
  head "https://github.com/bazelbuild/buildtools.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "b749c011792f0d8aa98700888833c2986a015aeb34f9d4f27beb6f0fe985d260"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./buildifier"
  end

  test do
    touch testpath/"BUILD"
    system bin/"buildifier", "-mode=check", "BUILD"
  end
end
