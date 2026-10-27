class Retry < Formula
  desc "Repeat a command until the command succeeds"
  homepage "https://github.com/minfrin/retry"
  url "https://github.com/minfrin/retry/releases/download/retry-1.0.7/retry-1.0.7.tar.bz2"
  sha256 "eb96b60244e09f407db9eb32cb9ad52361aaef4d19ca84817a6f88f577b60d6b"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "7fb3f16b144918aeae325a30be4fddb78e3e957c39c80c3c194bf6ec810aa386"
  end

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"retry.sh").write <<~SH
      attempt=0
      if [ -f attempts ]; then
        read -r attempt < attempts
      fi
      attempt=$((attempt + 1))
      echo "$attempt" > attempts
      [ "$attempt" -eq 3 ] || exit 1
      echo success
    SH

    assert_equal "success\n", shell_output("#{bin}/retry --quiet --delay 0 --times 3 -- sh retry.sh")
    assert_equal "3\n", (testpath/"attempts").read

    (testpath/"attempts").unlink
    shell_output("#{bin}/retry --quiet --delay 0 --times 2 -- sh retry.sh", 1)
    assert_equal "2\n", (testpath/"attempts").read
  end
end
