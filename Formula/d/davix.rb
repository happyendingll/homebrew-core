class Davix < Formula
  desc "Library and tools for advanced file I/O with HTTP-based protocols"
  homepage "https://github.com/cern-fts/davix"
  url "https://github.com/cern-fts/davix/releases/download/R_0_9_0/davix-0.9.0.tar.gz"
  sha256 "cf68461550fcd8fd88320658a42c55c7e7f6653e2be1461dfa95013adc56cced"
  license "LGPL-2.1-or-later"
  revision 1
  head "https://github.com/cern-fts/davix.git", branch: "devel"

  livecheck do
    url :stable
    regex(/^R[._-](\d+(?:[._]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.filter_map { |tag| tag[regex, 1]&.tr("_", ".") }
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "8b03fc4941e2066041962ea99268f908209808dfdbbf221bfe442e9da2450463"
  end

  depends_on "cmake" => :build
  depends_on "nlohmann-json" => :build
  depends_on "openssl@4"

  uses_from_macos "python" => :build
  uses_from_macos "curl", since: :monterey # needs CURLE_AUTH_ERROR, available since curl 7.66.0
  uses_from_macos "libxml2"

  on_linux do
    depends_on "util-linux"
  end

  # Apply open PR from Fedora to support OpenSSL 4
  patch do
    url "https://github.com/cern-fts/davix/commit/5223f92a8472489acb427552317b160facccec2b.patch?full_index=1"
    sha256 "77a143f47564cb2f8020d4bffe2754593e160512a52b6240f76ce5acb981a956"
    type :unofficial
    resolves "https://github.com/cern-fts/davix/pull/151"
  end

  allow_network_access! :test

  def install
    # Remove `-DCMAKE_POLICY_VERSION_MINIMUM=3.5` once fixed upstream
    # Issue ref: https://github.com/cern-fts/davix/issues/139
    args = %W[
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DLIB_SUFFIX=
      -DBENCH_TESTS=FALSE
      -DDAVIX_TESTS=FALSE
      -DEMBEDDED_LIBCURL=FALSE
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"davix-get", "https://brew.sh"
  end
end
