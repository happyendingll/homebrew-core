class DirectxHeaders < Formula
  desc "Official DirectX headers available under an open source license"
  homepage "https://devblogs.microsoft.com/directx/"
  url "https://github.com/microsoft/DirectX-Headers/archive/refs/tags/v1.620.2.tar.gz"
  sha256 "2b916ef1be5db35313f56d60499274fed39db37b54a1f0befa8aa49041c14855"
  license "MIT"
  compatibility_version 1

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "1d59d074e6daa802f5d02a531b6a282718c64647cca94c0cbba2be7c5d3aa378"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "mingw-w64" => :test

  resource "test.cpp", :test do
    url "https://raw.githubusercontent.com/microsoft/DirectX-Headers/a7d19030b872967c4224607c454273a2e65a5ed4/test/test.cpp"
    sha256 "6ff077a364a5f0f96b675d21aa8f053711fbef75bfdb193b44cc10b8475e2294"
  end

  def install
    system "meson", "setup", "build", "-Dbuild-test=false", *std_meson_args
    system "meson", "compile", "-C", "build"
    system "meson", "install", "-C", "build"
  end

  test do
    resource("test.cpp").stage(testpath)

    ENV.remove_macosxsdk if OS.mac?

    system formula_opt_bin("mingw-w64")/"x86_64-w64-mingw32-g++", "-I#{include}", "-c", "test.cpp"
  end
end
