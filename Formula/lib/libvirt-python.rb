class LibvirtPython < Formula
  desc "Libvirt virtualization API python binding"
  homepage "https://www.libvirt.org/"
  url "https://download.libvirt.org/python/libvirt_python-12.8.0.tar.gz"
  sha256 "ab24a102ebf99b913ddc3459031aa71a48b0b1cdbb0f423b4ea278052791ac8a"
  license "LGPL-2.1-or-later"
  revision 1

  livecheck do
    url "https://download.libvirt.org/python/"
    regex(/href=.*?libvirt[_-]python[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "04fcff7868d195ad7daaf6f70f26aecafc6904720b41d09bb8a76a5625923baf"
  end

  depends_on "pkgconf" => :build
  depends_on "python-setuptools" => :build
  depends_on "python@3.14" => [:build, :test]
  depends_on "python@3.15" => [:build, :test]
  depends_on "libvirt"

  deny_network_access!

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    pythons.each do |python|
      system python, "-m", "pip", "install", *std_pip_args, "."
    end
  end

  test do
    (testpath/"test.py").write <<~PYTHON
      import libvirt

      with libvirt.open('test:///default') as conn:
        if libvirt.virGetLastError() is not None:
          raise SystemError("Failed to open a test connection")
    PYTHON

    pythons.each do |python|
      system python, "test.py"
    end
  end
end
