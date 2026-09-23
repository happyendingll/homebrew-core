class OpenalSoft < Formula
  desc "Implementation of the OpenAL 3D audio API"
  homepage "https://openal-soft.org/"
  url "https://openal-soft.org/openal-releases/openal-soft-1.25.2.tar.bz2"
  sha256 "1dbaac44e7579d5bc8847ca8db4b2e8b9fd3961041f35ee20def4958301e1089"
  license "LGPL-2.0-or-later"
  compatibility_version 1
  head "https://github.com/kcat/openal-soft.git", branch: "master"

  livecheck do
    url :homepage
    regex(/href=.*?openal-soft[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "6871f253e9f0db6196661f18cdefb4f58a6a6371a412e3b515b87838d5b223a3"
  end

  keg_only :shadowed_by_macos, "macOS provides OpenAL.framework"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  on_macos do
    depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1699
  end

  on_linux do
    # Majority of Linux users do not need runtime dependencies as can use system libraries.
    # Others would still need to manually set up and configure an audio backend so
    # requiring any dependencies provides little to no benefit.
    depends_on "alsa-lib" => :build
    depends_on "dbus" => :build
    depends_on "pipewire" => :build
    depends_on "pulseaudio" => :build
  end

  fails_with :clang do
    build 1699
    cause "error: no member named 'join' in namespace 'std::ranges::views'"
  end

  deny_network_access!

  def install
    # Please don't re-enable example building. See:
    # https://github.com/Homebrew/homebrew/issues/38274
    args = %W[
      -DALSOFT_BACKEND_PORTAUDIO=OFF
      -DALSOFT_EXAMPLES=OFF
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]
    args += if OS.mac?
      %w[
        -DALSOFT_BACKEND_PULSEAUDIO=OFF
      ]
    else
      # Make sure support for common audio backends are available
      %w[
        -DALSOFT_REQUIRE_ALSA=ON
        -DALSOFT_REQUIRE_PIPEWIRE=ON
        -DALSOFT_REQUIRE_PULSEAUDIO=ON
      ]
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include "AL/al.h"
      #include "AL/alc.h"
      int main() {
        ALCdevice *device;
        device = alcOpenDevice(0);
        alcCloseDevice(device);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-o", "test", "-I#{include}", "-L#{lib}", "-lopenal"
    system "./test"
  end
end
