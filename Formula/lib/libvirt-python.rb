class LibvirtPython < Formula
  desc "Libvirt virtualization API python binding"
  homepage "https://www.libvirt.org/"
  url "https://download.libvirt.org/python/libvirt_python-12.7.0.tar.gz"
  sha256 "03a6800a3cc7657267e2516f579ce95c93d6351182caf03f92a49556685bf8bf"
  license "LGPL-2.1-or-later"

  livecheck do
    url "https://download.libvirt.org/python/"
    regex(/href=.*?libvirt[_-]python[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "59294034d99d155e5fee4798c8496a1781dca2fc23a1ce6b360fff157c89a8c9"
  end

  depends_on "pkgconf" => :build
  depends_on "libvirt"
  depends_on "python@3.14"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    pythons.each do |python|
      system python, "-m", "pip", "install", *std_pip_args(build_isolation: true), "."
    end
  end

  test do
    pythons.each do |python|
      system python, "-c",
             <<~PYTHON
               import libvirt

               with libvirt.open('test:///default') as conn:
                   if libvirt.virGetLastError() is not None:
                       raise SystemError("Failed to open a test connection")
             PYTHON
    end
  end
end
