class Astyle < Formula
  desc "Source code beautifier for C, C++, C#, and Java"
  homepage "https://astyle.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/astyle/astyle/astyle%203.6/astyle-3.6.19.tar.bz2"
  sha256 "ae5ef4ddf1f88288bcc8f6d53266707f80a81fcc6decf4da5fe5c8e420a0ab1c"
  license "MIT"
  head "https://svn.code.sf.net/p/astyle/code/trunk/AStyle"

  livecheck do
    url :stable
    regex(%r{url=.*?/astyle[._-]v?(\d+(?:\.\d+)+)(?:[._-]linux)?\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "8f3f948fd5f9df4d35cc198b83d7e0ed13d0e0e6fdf612f4e15bfba254d0d592"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    man1.install "man/astyle.1"
  end

  test do
    (testpath/"test.c").write("int main(){return 0;}\n")
    system bin/"astyle", "--style=gnu", "--indent=spaces=4",
           "--lineend=linux", testpath/"test.c"
    assert_equal File.read("test.c"), <<~C
      int main()
      {
          return 0;
      }
    C
  end
end
