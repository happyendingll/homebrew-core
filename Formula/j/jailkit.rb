class Jailkit < Formula
  desc "Utilities to create limited user accounts in a chroot jail"
  homepage "https://olivier.sessink.nl/jailkit/"
  url "https://olivier.sessink.nl/jailkit/jailkit-2.23.tar.bz2"
  sha256 "aa27dc1b2dbbbfcec2b970731f44ced7079afc973dc066757cea1beb4e8ce59c"
  license all_of: ["BSD-3-Clause", "LGPL-2.0-or-later"]
  revision 1

  livecheck do
    url :homepage
    regex(/href=.*?jailkit[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "1048442bc15f29356c4765d2fafc88970ebced206ea96b89fbb24178616092b1"
  end

  depends_on "python@3.15"

  deny_network_access!

  def install
    ENV["PYTHONINTERPRETER"] = python3

    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    jail = testpath/"jail"
    (jail/"etc").mkpath
    (jail/"tmp").mkpath
    chmod 0777, jail/"tmp"
    (testpath/"jk_check.ini").write "[#{jail}]\n"

    output = shell_output("#{sbin}/jk_check -c #{testpath}/jk_check.ini 2>&1")
    assert_match "ERROR: #{jail} is not owned by root:root!", output
    assert_match "WARNING: #{jail}/tmp/ is writable for others!", output
  end
end
