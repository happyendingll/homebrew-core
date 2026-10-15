class VapoursynthDescale < Formula
  desc "VapourSynth plugin to undo upscaling"
  homepage "https://github.com/Irrational-Encoding-Wizardry/descale"
  url "https://github.com/Irrational-Encoding-Wizardry/descale/archive/refs/tags/r8.tar.gz"
  sha256 "317d955cc2dfbc3fd1aecef2ea2d56e4f1cd99434492d71c6a1d48213ff35972"
  license "MIT"
  revision 2
  head "https://github.com/Irrational-Encoding-Wizardry/descale.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "3c451322028fb97cdacdfb3779acdf949d40697d66772b12bc9abab9232f79dd"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.15"
  depends_on "vapoursynth"

  def install
    # Help outdated #includes paths find VapourSynth
    vapoursynth_dir = "#{Language::Python.site_packages(python3)}/vapoursynth"
    buildpath.install_symlink formula_opt_libexec("vapoursynth")/vapoursynth_dir/"include" => "vapoursynth"

    # Upstream build system wants to install directly into vapoursynth's libdir and does not respect
    # prefix, but we want it in a Cellar location instead.
    inreplace "meson.build",
              "installdir = join_paths(vs.get_pkgconfig_variable('libdir'), 'vapoursynth')",
              "installdir = '#{prefix/vapoursynth_dir}/plugins'"

    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    system python3, "-c", "from vapoursynth import core; core.descale"
  end
end
