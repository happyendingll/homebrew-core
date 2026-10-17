class Xmake < Formula
  desc "Cross-platform build utility based on Lua"
  homepage "https://xmake.io/"
  url "https://github.com/xmake-io/xmake/releases/download/v3.1.2/xmake-v3.1.2.tar.gz"
  sha256 "0e068e76c66dddd87573a31b77f37c8c4ebe7d50b0fb48d507dcb902c77e6cc4"
  license "Apache-2.0"
  head "https://github.com/xmake-io/xmake.git", branch: "dev"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "4cb008d0e429433134615dd75a9fb755d091485a73a1435846634217d7a18e3c"
  end

  uses_from_macos "ncurses"

  on_linux do
    depends_on "readline"
  end

  deny_network_access!

  def install
    system "./configure"
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    ENV.delete "CPATH"
    system bin/"xmake", "create", "test"
    cd "test" do
      system bin/"xmake"
      assert_equal "hello world!", shell_output("#{bin}/xmake run").chomp
    end
  end
end
