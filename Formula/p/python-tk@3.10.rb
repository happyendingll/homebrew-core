class PythonTkAT310 < Formula
  desc "Python interface to Tcl/Tk"
  homepage "https://www.python.org/"
  url "https://www.python.org/ftp/python/3.10.22/Python-3.10.22.tgz"
  sha256 "9448b34d16f8e3db0964ac3ed9fb283197747543c2c021f283ffd2c8b7287357"
  license "Python-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "93d17430fe08d978888cefe7ffa9e8ef1ed1f43f30c975bc7f11a7c1834bc74b"
  end

  keg_only :versioned_formula

  # https://devguide.python.org/versions/#unsupported-versions
  deprecate! date: "2026-10-01", because: :deprecated_upstream
  disable! date: "2027-10-01", because: :deprecated_upstream

  depends_on "python@3.10"
  depends_on "tcl-tk@8"

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
