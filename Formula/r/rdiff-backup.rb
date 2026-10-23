class RdiffBackup < Formula
  include Language::Python::Virtualenv

  desc "Reverse differential backup tool, over a network or locally"
  homepage "https://rdiff-backup.net/"
  url "https://files.pythonhosted.org/packages/ab/23/3fab9ee2a2691859bcd99601682806cd86f530bfeaff13d284c5f1f8bfae/rdiff_backup-2.2.7.tar.gz"
  sha256 "a88a1eb895f3c6c7dcc12d897ab53e301f9f49c9ac61b05039be212891c7d5d7"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "9dd35cf2dc3e7630612a71c60fb359da70a57a85a1fac2c0344573cd1735587b"
  end

  depends_on "librsync"
  depends_on "libyaml"
  depends_on "python@3.15"

  pypi_packages extra_packages: "pyxattr"

  resource "pyxattr" do
    url "https://files.pythonhosted.org/packages/97/d1/7b85f2712168dfa26df6471082403013f3f815f3239aee3def17b6fd69ee/pyxattr-0.8.1.tar.gz"
    sha256 "48c578ecf8ea0bd4351b1752470e301a90a3761c7c21f00f953dcf6d6fa6ee5a"
  end

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system bin/"rdiff-backup", "--version"
  end
end
