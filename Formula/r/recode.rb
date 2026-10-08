class Recode < Formula
  desc "Convert character set (charsets)"
  homepage "https://github.com/rrthomas/recode"
  url "https://github.com/rrthomas/recode/releases/download/v3.7.17/recode-3.7.17.tar.gz"
  sha256 "1b0aebe7283b79ff46bc0a06ee21faf65b4d0b304632cbc855721c25583d8ea3"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "0628133b43c93d3e72118fa44a533dbd7d673d4b9427fd250169f78b9746dc95"
  end

  uses_from_macos "python" => :build

  on_macos do
    depends_on "gettext"
  end

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/recode --version")
  end
end
