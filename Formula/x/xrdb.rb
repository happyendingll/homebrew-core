class Xrdb < Formula
  desc "X resource database utility"
  homepage "https://gitlab.freedesktop.org/xorg/app/xrdb"
  url "https://www.x.org/releases/individual/app/xrdb-1.2.3.tar.xz"
  sha256 "c88f560243278c896ce4fc92ae5a45a2b505a316ffa427fe55b02e5d5914c4e4"
  license all_of: ["MIT-open-group", "HPND-DEC"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "a4fcabcdf0e07b97d91b0d6362b5cd5d6f65851082a716e20c517dddf8580a9c"
  end

  depends_on "pkgconf" => :build
  depends_on "xorg-server" => :test

  depends_on "libx11"
  depends_on "libxmu"

  def install
    system "./configure", "--with-cpp=/usr/bin/cpp", *std_configure_args
    system "make", "install"
  end

  test do
    IO.pipe do |read_io, write_io|
      xvfb = formula_opt_bin("xorg-server")/"Xvfb"
      pid = spawn(xvfb, "-displayfd", write_io.fileno.to_s, "-listen", "tcp", write_io => write_io)
      write_io.close
      ENV["DISPLAY"] = ":#{read_io.read.strip}"
      system bin/"xrdb", "-query"
    ensure
      if pid
        Process.kill "TERM", pid
        Process.wait pid
      end
    end
  end
end
