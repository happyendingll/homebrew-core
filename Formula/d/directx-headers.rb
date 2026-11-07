class DirectxHeaders < Formula
  desc "Official DirectX headers available under an open source license"
  homepage "https://devblogs.microsoft.com/directx/"
  url "https://github.com/microsoft/DirectX-Headers/archive/refs/tags/v1.620.1.tar.gz"
  sha256 "79cd6d5b87d940044b20a3f45e5fbf4a73e4c7eedc1bafabe1b5cabb97fef5bf"
  license "MIT"
  compatibility_version 1

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "576ae4fce00dc6b5a20fb7fa563e3cd1897832049a0a57a28a78b41338e498c4"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "mingw-w64" => :test

  resource "test.cpp", :test do
    url "https://raw.githubusercontent.com/microsoft/DirectX-Headers/a7d19030b872967c4224607c454273a2e65a5ed4/test/test.cpp"
    sha256 "6ff077a364a5f0f96b675d21aa8f053711fbef75bfdb193b44cc10b8475e2294"
  end

  # Add missing SAL annotations to the non-Windows stubs
  patch do
    url "https://github.com/microsoft/DirectX-Headers/commit/d0b4f7936049872552249707a149dc2837ac03ef.patch?full_index=1"
    sha256 "9beaeda49cc1fae1a0b9f43a2b2d5be8d517184a1635b3bde7cc4d808cc36ae8"
    type :backport
    resolves "https://github.com/microsoft/DirectX-Headers/issues/295"
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
