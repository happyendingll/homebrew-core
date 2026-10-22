class Vifm < Formula
  desc "Ncurses-based file manager with vi-like keybindings"
  homepage "https://vifm.info/"
  url "https://github.com/vifm/vifm/releases/download/v0.14.5/vifm-0.14.5.tar.bz2"
  sha256 "5de33fd6637ce91cdce162358ec393f6fe5e9734deb1833ea16776d619960422"
  license "GPL-2.0-or-later"
  head "https://github.com/vifm/vifm.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "6248e53339ab10be430aef0b150ba5298dc95a383d11861128ca64215b457a73"
  end

  depends_on "ncurses"

  uses_from_macos "mandoc" => :build

  deny_network_access!

  def install
    args = %W[
      --with-curses=#{formula_opt_prefix("ncurses")}
      --without-gtk
      --without-libmagic
      --without-X11
    ]

    system "./configure", *args, *std_configure_args
    system "make"
    ENV.deparallelize { system "make", "install" }
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vifm --version")
  end
end
