class Remind < Formula
  desc "Sophisticated calendar and alarm"
  homepage "https://dianne.skoll.ca/projects/remind/"
  url "https://dianne.skoll.ca/projects/remind/download/remind-06.03.07.tar.gz"
  sha256 "38b2afaf4cc2ef5642c8ea85c61c3658d575a381be58baf4a5a05f419a9637a2"
  license "GPL-2.0-only"
  head "https://git.skoll.ca/Skollsoft-Public/Remind.git", branch: "master"

  livecheck do
    url :homepage
    regex(%r{href=.*?/download/remind-(\d+(?:[._]\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 sequoia: "2138e92ff5097005e6ddfc9eff536c757b23ee7df46a72f6c9aaf07d8f3cdbb0"
  end

  conflicts_with "rem", because: "both install `rem` binaries"

  deny_network_access!

  def install
    # Exclude unrecognized options
    args = std_configure_args.reject { |s| s["--disable-debug"] || s["--disable-dependency-tracking"] }

    system "./configure", *args
    system "make", "-C", "src", "install"
    system "make", "-C", "rem2html", "install"
  end

  test do
    (testpath/"reminders.rem").write <<~REM
      SET $OnceFile "./once.timestamp"
      REM ONCE 2015-01-01 MSG Homebrew Test
    REM
    assert_equal "Reminders for Thursday, 1st January, 2015:\n\nHomebrew Test\n\n",
      shell_output("#{bin}/remind reminders.rem 2015-01-01")
  end
end
