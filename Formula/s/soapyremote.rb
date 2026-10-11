class Soapyremote < Formula
  desc "Use any Soapy SDR remotely"
  homepage "https://github.com/pothosware/SoapyRemote/wiki"
  url "https://github.com/pothosware/SoapyRemote/archive/refs/tags/soapy-remote-0.5.3.tar.gz"
  sha256 "de5bdf209dc93bf7c341077e1e21353037fc387e7c6a9ee41eace3390669dcc1"
  license "BSL-1.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "ffe49e8b17fcea3a6e599e2c4b760c70e3f4fb5561bfcb19556990349b70f70e"
  end

  depends_on "cmake" => :build
  depends_on "soapysdr"

  deny_network_access!

  def install
    # Workaround to build with CMake 4
    args = %w[-DCMAKE_POLICY_VERSION_MINIMUM=3.5]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    output = shell_output("#{formula_opt_bin("soapysdr")}/SoapySDRUtil --check=remote")
    assert_match "Checking driver 'remote'... PRESENT", output
  end
end
