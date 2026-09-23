class HfMount < Formula
  desc "Mount Hugging Face Buckets and repos as local filesystems"
  homepage "https://github.com/huggingface/hf-mount"
  url "https://github.com/huggingface/hf-mount/archive/refs/tags/v0.12.0.tar.gz"
  sha256 "eb51765d6783b39ced2a7a94c793ca1b5d368919727c961c826ce36d0734d2b2"
  license "Apache-2.0"
  head "https://github.com/huggingface/hf-mount.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "d2d69c73a550ba910fec3b829491e90d1ce81b66a6332fa0590535de0777d1d1"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "libfuse"
    depends_on "openssl@4"
  end

  def install
    # macOS FUSE needs closed-source macFUSE (not allowed in homebrew/core)
    features = ["nfs"]
    bins = ["hf-mount", "hf-mount-nfs"]
    if OS.linux?
      features << "fuse"
      bins << "hf-mount-fuse"
    end

    bins.each do |bin_name|
      system "cargo", "install", "--no-default-features",
             "--bin", bin_name, *std_cargo_args(features:)
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hf-mount --version")

    # Daemon registry commands work offline and exercise the PID-file machinery.
    assert_match "No running daemons", shell_output("#{bin}/hf-mount status 2>&1")
    assert_match "no daemon found",
                 shell_output("#{bin}/hf-mount stop #{testpath}/nothing 2>&1", 1)
  end
end
