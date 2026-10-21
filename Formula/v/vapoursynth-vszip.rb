class VapoursynthVszip < Formula
  desc "VapourSynth Zig Image Process"
  homepage "https://github.com/dnjulek/vapoursynth-zip"
  url "https://files.pythonhosted.org/packages/ac/5b/46cc32a9236271e709904c88056f053a731973c7358f4be44830aa242c9f/vapoursynth_vszip-23.0.0.tar.gz"
  sha256 "7ef229ccbe9484a9a7b4b28f0535bcdc10e2e51386c9ba085f49f3134d2e85f1"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "5815c68c18be180d7228fd2ca10dca45b0da387a61e5511b2409d8f85769ad6a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "130410f45b7cbcf5d6f0f1a82acba050a78d7a6217114c3e4fdab9f16665b677"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "6ecf3844e37bac1a3bbae46b448fad74a0c0d4192a05ec4fd865e185cd5c3ee2"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "4e1c5855caab6c1e905ab84859df0380e1794896475ba8c03e31070b02879964"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "1fb6f0660655da12d07ad3fc5a85e3fbc22d492cc1ca00dfa85ee9d145c5f910"
  end

  depends_on "zig" => :build
  depends_on "python@3.15"
  depends_on "vapoursynth"

  preserve_rpath # skip unnecessary relocation for plugin which avoids headerpad errors

  pypi_packages exclude_packages: "vapoursynth"

  deny_network_access!

  def fetch
    system "zig", "build", "--fetch"
  end

  def install
    plugindir = "#{Language::Python.site_packages(python3)}/vapoursynth/plugins"
    system "zig", "build", "--prefix-lib-dir", plugindir, *std_zig_args
  end

  test do
    (testpath/"test.py").write <<~PYTHON
      from vapoursynth import core
      print(core.vszip.ImageRead("#{test_fixtures("test.png")}"))
    PYTHON
    assert_match "Width: 8", shell_output("#{python3} test.py")
  end
end
