class Buildifier < Formula
  desc "Format bazel BUILD files with a standard convention"
  homepage "https://github.com/bazelbuild/buildtools"
  url "https://github.com/bazelbuild/buildtools/archive/refs/tags/v10.2.0.tar.gz"
  sha256 "5af90068e9e8812abdc455ad04cc474470bccc8bbabc8b571e3f58a66799680f"
  license "Apache-2.0"
  head "https://github.com/bazelbuild/buildtools.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "356c61f2f77e3c6950468c6cd135e7c5c336b85ef07f4f259cd324855810b1fa"
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
