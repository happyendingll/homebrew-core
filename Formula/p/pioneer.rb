class Pioneer < Formula
  desc "Game of lonely space adventure"
  homepage "https://pioneerspacesim.net/"
  url "https://github.com/pioneerspacesim/pioneer/archive/refs/tags/20260907.tar.gz"
  sha256 "11d1fbf745f5fc710f30cce02065b60e5aeb05f7c79b2cfdde8b4c64ec132491"
  license "GPL-3.0-only"
  head "https://github.com/pioneerspacesim/pioneer.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "7bd655b5cc91b33a450316be22a5d976cfe45c29c64ee9dfc528bce7e673a8ae"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "assimp"
  depends_on "freetype"
  depends_on "glew"
  depends_on "libpng"
  depends_on "libsigc++@2"
  depends_on "libvorbis"
  depends_on "openal-soft"
  depends_on "sdl2-compat"
  depends_on "sdl2_image"

  on_linux do
    depends_on "mesa"
  end

  # patch to fix ambiguous `to_string` overloads
  patch do
    on_macos do
      url "https://github.com/pioneerspacesim/pioneer/commit/24023dfa75b1bd9de15b45692aeedab26da1b1b7.patch?full_index=1"
      sha256 "9279afa54507c971ea517f508c1796b0ce9dc435d976778d13bfea7813056908"
      type :unofficial
      resolves "https://github.com/pioneerspacesim/pioneer/pull/6286"
    end
  end

  # patch to fix `pi_lua_generic_push` call
  patch do
    url "https://github.com/pioneerspacesim/pioneer/commit/9293a5f84584d7dd10699c64f28647a576ca059b.patch?full_index=1"
    sha256 "c93e0f8745d9e1dc7989a0051489be7825df452e0d1fa0cf654038f1486e2f9f"
    type :unofficial
    resolves "https://github.com/pioneerspacesim/pioneer/pull/6000"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", "-DCMAKE_POLICY_VERSION_MINIMUM=3.5", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match "pioneer #{version}", shell_output("#{bin}/pioneer -v 2>&1").chomp
    assert_match "modelcompiler #{version}", shell_output("#{bin}/modelcompiler -v 2>&1").chomp
  end
end
