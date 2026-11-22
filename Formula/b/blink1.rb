class Blink1 < Formula
  desc "Control blink(1) indicator light"
  homepage "https://blink1.thingm.com/"
  url "https://github.com/todbot/blink1-tool.git",
      tag:      "v2.6.0",
      revision: "74db9b7acfb4666b6afc5dab830779845112b1ea"
  license any_of: ["CC-BY-SA-4.0", "MIT"]
  head "https://github.com/todbot/blink1-tool.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "9dff04d9dce30e7d1935a652a5bec75bcd0864aa87a6f2d2631ca6e6655e8681"
  end

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "systemd"
  end

  deny_network_access!

  def install
    mkdir_p [bin, include, lib/"pkgconfig"]
    system "make"
    system "make", "install", "install-dev", "PREFIX=#{prefix}"
  end

  test do
    system bin/"blink1-tool", "--version"
  end
end
