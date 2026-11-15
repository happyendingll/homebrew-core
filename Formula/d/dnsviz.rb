class Dnsviz < Formula
  include Language::Python::Virtualenv

  desc "Tools for analyzing and visualizing DNS and DNSSEC behavior"
  homepage "https://github.com/dnsviz/dnsviz/"
  url "https://files.pythonhosted.org/packages/50/33/de6ddf145bdb6c94ee25b33bc314af3bdbd15950c5a4647295da224ab58f/dnsviz-0.11.2.tar.gz"
  sha256 "ca136788bd868c03b1f2653575d899ffef41a016711655c0ee65f89c1bea3514"
  license "GPL-2.0-or-later"
  revision 2

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "f8d409b17254386b5b8d41c3249d8bc1ab9195aff7eaefe7ef5ff46b807fba6f"
  end

  depends_on "bind" => [:build, :test]
  depends_on "pkgconf" => :build
  depends_on "rust" => :build # for dnspython > uv_build > maturin
  depends_on "swig" => :build
  depends_on "json-c" => :test
  depends_on "cryptography" => :no_linkage
  depends_on "graphviz"
  depends_on "python@3.15"

  pypi_packages extra_packages: ["dnspython", "pygraphviz", "setuptools"]

  resource "dnspython" do
    url "https://files.pythonhosted.org/packages/76/49/900383b471c645a3c397f47b3211d1fcecb3a540c98f683494cdf86b33de/dnspython-2.9.2.tar.gz"
    sha256 "8d4d39a513e649d634004ce4d39ade2352efcea472a0247535a5c2d18a9d7ba9"
  end

  resource "pygraphviz" do
    url "https://files.pythonhosted.org/packages/f5/56/92b970deefddb2c31f92a9c8c794db89e4d6562a8a11af93269107cf30d2/pygraphviz-2.0.4.tar.gz"
    sha256 "510164db9abc5b7ffd79007ed94638958c0190c8206853b07dda05fa1050b829"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/70/b3/c19426f783614d625699a4b247faf628ea9ab1db228674491767b417f9e1/setuptools-84.2.1.tar.gz"
    sha256 "3ff8b3b5492a0aa66960f4419365a86b84e013070d4313e4d4a6894f5d64d6bc"
  end

  resource "example-com-probe-auth", :test do
    url "https://raw.githubusercontent.com/dnsviz/dnsviz/refs/heads/master/tests/zones/unsigned/example.com-probe-auth.json"
    sha256 "6d75bf4e6289db41f8da6263aed2e0e8c910b8f303e4f065ec7d359997248997"

    livecheck do
      skip "Test fixture"
    end
  end

  def install
    # TODO: Remove when PyGraphviz discovers nonstandard Graphviz prefixes.
    # https://github.com/pygraphviz/pygraphviz/issues/630
    if OS.linux?
      graphviz_prefix = formula_opt_prefix("graphviz")
      ENV["GRAPHVIZ_PREFIX"] = graphviz_prefix
      ENV.append "LDFLAGS", "-Wl,-rpath,#{graphviz_prefix}/lib/graphviz"
    end
    venv = virtualenv_create(libexec, python3)
    venv.pip_install resources.reject { |r| r.test? || r.name == "pygraphviz" }
    # Use Homebrew's SWIG instead of rebuilding it in pip's isolated environment.
    venv.pip_install resource("pygraphviz"), build_isolation: false
    venv.pip_install_and_link buildpath
  end

  test do
    resource("example-com-probe-auth").stage do
      system bin/"dnsviz", "probe", "-d", "0",
        "-r", "example.com-probe-auth.json",
        "-o", "example.com.json"
      system bin/"dnsviz", "graph", "-r", "example.com.json", "-Thtml", "-o", File::NULL
      system bin/"dnsviz", "grok", "-r", "example.com.json", "-o", File::NULL
      system bin/"dnsviz", "print", "-r", "example.com.json", "-o", File::NULL
    end
  end
end
