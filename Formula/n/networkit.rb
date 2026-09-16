class Networkit < Formula
  desc "Performance toolkit for large-scale network analysis"
  homepage "https://networkit.github.io"
  url "https://github.com/networkit/networkit/archive/refs/tags/11.2.2.tar.gz"
  sha256 "04fffd0f801a91524a6dc2643f7d262e79600b086e4688bcb1b7988b2b5448dd"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "e68cbbdfd976dab635aad93331febaa209e2bd936fac1129071fd7d300de1826"
  end

  depends_on "cmake" => :build
  depends_on "cython" => :build
  depends_on "ninja" => :build
  depends_on "python-setuptools" => :build
  depends_on "tlx" => :build

  depends_on "libnetworkit"
  depends_on "numpy"
  depends_on "python@3.14"
  depends_on "scipy"

  on_macos do
    depends_on "libomp"
  end

  # Fix build with Cython 3.3 (duplicate `__pyx_convert_vector_to_py_*` definitions)
  patch do
    url "https://github.com/networkit/networkit/commit/11bbe357057f886ef8864565f981c4f86a47b8ce.patch?full_index=1"
    sha256 "495247630a1a1810c6db057b58c27a82777710e7a9ec77e2c6abdeff18e6919d"
    type :unofficial
    resolves "https://github.com/networkit/networkit/pull/1519"
  end

  def install
    site_packages = Language::Python.site_packages(python3)

    ENV.prepend_create_path "PYTHONPATH", prefix/site_packages
    ENV.append_path "PYTHONPATH", formula_opt_libexec("cython")/site_packages

    networkit_site_packages = prefix/site_packages/"networkit"
    extra_rpath = rpath(source: networkit_site_packages, target: formula_opt_lib("libnetworkit"))
    system python3, "setup.py", "build_ext", "--networkit-external-core",
                                             "--external-tlx=#{formula_opt_prefix("tlx")}",
                                             "--rpath=#{loader_path};#{extra_rpath}"

    system python3, "-m", "pip", "install", *std_pip_args, "."
  end

  test do
    system python3, "-c", <<~PYTHON
      import networkit as nk
      G = nk.graph.Graph(3)
      G.addEdge(0,1)
      G.addEdge(1,2)
      G.addEdge(2,0)
      assert G.degree(0) == 2
      assert G.degree(1) == 2
      assert G.degree(2) == 2
    PYTHON
  end
end
