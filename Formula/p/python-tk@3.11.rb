class PythonTkAT311 < Formula
  desc "Python interface to Tcl/Tk"
  homepage "https://www.python.org/"
  url "https://www.python.org/ftp/python/3.11.18/Python-3.11.18.tgz"
  sha256 "5f62711b12470fd435f83f1451c1b1ef4a179aebc715c716874b0967567d814e"
  license "Python-2.0"

  livecheck do
    formula "python@3.11"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "65864830a6be420dded21ece377b268a6141ba02d24c89547bec41b8f31edaaa"
  end

  # https://devguide.python.org/versions/#versions
  # https://sourceforge.net/p/tcl/mailman/message/59333692/
  deprecate! date: "2026-10-04", because: "needs EOL Tcl/Tk 8.6"
  disable! date: "2028-01-01", because: :deprecated_upstream

  depends_on "python@3.11"
  depends_on "tcl-tk@8"

  deny_network_access!

  def install
    cd "Modules" do
      tcltk = Formula["tcl-tk@8"]
      tcltk_version = tcltk.any_installed_version.major_minor
      Pathname("setup.py").write <<~PYTHON
        from setuptools import setup, Extension

        setup(name="tkinter",
              description="#{desc}",
              version="#{version}",
              ext_modules = [
                Extension("_tkinter", ["_tkinter.c", "tkappinit.c"],
                          define_macros=[("WITH_APPINIT", 1)],
                          include_dirs=["#{tcltk.opt_include/"tcl-tk"}"],
                          libraries=["tcl#{tcltk_version}", "tk#{tcltk_version}"],
                          library_dirs=["#{tcltk.opt_lib}"])
              ]
        )
      PYTHON
      system python3, "-m", "pip", "install", *std_pip_args(prefix: false), "--target=#{libexec}", "."
      rm_r libexec.glob("*.dist-info")
    end
  end

  test do
    system python3, "-c", "import tkinter"
  end
end
