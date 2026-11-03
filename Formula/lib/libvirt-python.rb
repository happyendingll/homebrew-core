class LibvirtPython < Formula
  desc "Libvirt virtualization API python binding"
  homepage "https://www.libvirt.org/"
  url "https://download.libvirt.org/python/libvirt_python-12.9.0.tar.gz"
  sha256 "598b85cd1f5e94b97684b725cd45a65f6ab734c6edaa61d4aec98721f30e9401"
  license "LGPL-2.1-or-later"
  compatibility_version 1

  livecheck do
    url "https://download.libvirt.org/python/"
    regex(/href=.*?libvirt[_-]python[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "9eece9a38a88689d735d2df032a0fce252a5986c13bc951a6ecf7795b747568e"
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
