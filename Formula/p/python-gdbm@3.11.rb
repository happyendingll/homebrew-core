class PythonGdbmAT311 < Formula
  desc "Python interface to gdbm"
  homepage "https://www.python.org/"
  url "https://www.python.org/ftp/python/3.11.17/Python-3.11.17.tgz"
  sha256 "53cdee63ac4bf12387b7b33a53d3b1f8f4941cad73807a7b4fe91bb001ef004a"
  license "Python-2.0"

  livecheck do
    formula "python@3.11"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "5c955c21f58f4b2eb09325030479bbd008629c21ac9bee7fbdd0805865503bed"
  end

  # https://devguide.python.org/versions/#versions
  deprecate! date: "2027-11-01", because: :deprecated_upstream
  disable! date: "2028-11-01", because: :deprecated_upstream

  depends_on "gdbm"
  depends_on "python@3.11"

  def install
    cd "Modules" do
      (Pathname.pwd/"setup.py").write <<~PYTHON
        from setuptools import setup, Extension

        setup(name="gdbm",
              description="#{desc}",
              version="#{version}",
              ext_modules = [
                Extension("_gdbm", ["_gdbmmodule.c"],
                          include_dirs=["#{formula_opt_include("gdbm")}"],
                          libraries=["gdbm"],
                          library_dirs=["#{formula_opt_lib("gdbm")}"])
              ]
        )
      PYTHON
      system python3, "-m", "pip", "install", *std_pip_args(prefix: false), "--target=#{libexec}", "."
      rm_r libexec.glob("*.dist-info")
    end
  end

  test do
    testdb = testpath/"test.db"
    system python3, "-c", <<~PYTHON
      import dbm.gnu

      with dbm.gnu.open("#{testdb}", "n") as db:
        db["testkey"] = "testvalue"

      with dbm.gnu.open("#{testdb}", "r") as db:
        assert db["testkey"] == b"testvalue"
    PYTHON
  end
end
