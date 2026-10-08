class Mailcheck < Formula
  desc "Check multiple mailboxes/maildirs for mail"
  homepage "https://mailcheck.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/mailcheck/mailcheck/1.91.2/mailcheck_1.91.2.tar.gz"
  sha256 "6ca6da5c9f8cc2361d4b64226c7d9486ff0962602c321fc85b724babbbfa0a5c"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "730888e37af344324c6b06900ba69df3758628e0b053ff9538ff42d5458250bb"
  end

  deny_network_access!

  def install
    system "make", "mailcheck"
    bin.install "mailcheck"
    man1.install "mailcheck.1"
    etc.install "mailcheckrc"
  end

  test do
    ENV["HOME"] = testpath
    %w[cur new tmp].each { |d| (testpath/"Maildir"/d).mkpath }
    touch testpath/"Maildir/new/1"
    touch testpath/"Maildir/new/2"
    touch testpath/"Maildir/cur/3"
    (testpath/".mailcheckrc").write "$(HOME)/Maildir\n"

    assert_equal "You have 2 new and 1 saved messages in #{testpath}/Maildir",
                 shell_output("#{bin}/mailcheck").strip

    # Login mode exits silently when ~/.hushlogin exists
    touch testpath/".hushlogin"
    assert_empty shell_output("#{bin}/mailcheck -l")
  end
end
