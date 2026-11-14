class Soapyremote < Formula
  desc "Use any Soapy SDR remotely"
  homepage "https://github.com/pothosware/SoapyRemote/wiki"
  url "https://github.com/pothosware/SoapyRemote/archive/refs/tags/soapy-remote-0.5.4.tar.gz"
  sha256 "7109077f9f64c530c26604d2f30437d4403d6133df50e600c3c7e022a622521c"
  license "BSL-1.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "bb48805202a1f272c332470a3ee23fb02911eff13c513d686c51ebfe62949acd"
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
