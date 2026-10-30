class MkConfigure < Formula
  desc "Lightweight replacement for GNU autotools"
  homepage "https://github.com/cheusov/mk-configure"
  url "https://downloads.sourceforge.net/project/mk-configure/mk-configure/mk-configure-0.40.3/mk-configure-0.40.3.tar.gz"
  sha256 "3b70b7ffe817a386b13bca7f685fb068d7fd7925a51c9710a8557487d5f1c732"
  license all_of: ["BSD-2-Clause", "BSD-3-Clause", "MIT", "MIT-CMU"]
  compatibility_version 1

  livecheck do
    url :stable
    regex(%r{url=.*?/mk-configure[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "1c64d06eeebb399f0321869f8e0f1a0295de8c2422bf2afb7f250281777a2ec1"
  end

  depends_on "bmake"
  depends_on "makedepend"

  def install
    ENV["PREFIX"] = prefix
    ENV["MANDIR"] = man

    system "bmake", "all"
    system "bmake", "install"
    doc.install "presentation/presentation.pdf"
  end

  test do
    system bin/"mkcmake", "-V", "MAKE_VERSION", "-f", File::NULL
  end
end
