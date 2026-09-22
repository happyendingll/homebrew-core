class Bonniexx < Formula
  desc "Benchmark suite for file systems and hard drives"
  homepage "https://www.coker.com.au/bonnie++/"
  url "https://www.coker.com.au/bonnie++/bonnie++-2.00a.tgz"
  sha256 "a8d33bbd81bc7eb559ce5bf6e584b9b53faea39ccfb4ae92e58f27257e468f0e"
  license "GPL-2.0-only"

  livecheck do
    url "https://doc.coker.com.au/projects/bonnie/"
    regex(/href=.*?bonnie\+\+[._-]v?(\d+(?:\.\d+)+[a-z]?)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "655253cf10e36a8fb90e4db3b95cc80b5c455f6f866e40fac0619c25ce91ccaa"
  end

  # Remove the #ifdef _LARGEFILE64_SOURCE macros which not only prohibits the
  # intended functionality of splitting into 2 GB files for such filesystems but
  # also incorrectly tests for it in the first place. The ideal fix would be to
  # replace the AC_TRY_RUN() in configure.in if the fail code actually worked.
  patch do
    file "Patches/bonnie++/remove-large-file-support-macros.diff"
    type :unofficial
  end

  def install
    ENV.cxx11
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    system sbin/"bonnie++", "-s", "0"
  end
end
