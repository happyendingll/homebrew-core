class Par2 < Formula
  desc "Parchive: Parity Archive Volume Set for data recovery"
  homepage "https://parchive.github.io"
  url "https://github.com/Parchive/par2cmdline/releases/download/v2.0.0/par2cmdline-2.0.0.tar.bz2"
  sha256 "93b8403d6304bcfbfe5bc5a619099496bfe3510c48b73dae6c26127eeaa91cbb"
  license "GPL-2.0-or-later"
  head "https://github.com/Parchive/par2cmdline.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "456be4ad9182f156275a5c8bc800a9767c9ab2605b5b62412c54038cbc0eb47b"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # Protect a file with par2.
    test_file = testpath/"some-file"
    test_file.write "file contents"
    system bin/"par2", "create", test_file

    # "Corrupt" the file by overwriting, then ask par2 to repair it.
    File.write test_file, "corrupted contents"
    repair_command_output = shell_output("#{bin}/par2 repair #{test_file}")

    # Verify that par2 claimed to repair the file.
    assert_match "1 file(s) exist but are damaged.", repair_command_output
    assert_match "Repair complete.", repair_command_output

    # Verify that par2 actually repaired the file.
    assert_equal "file contents", test_file.read
  end
end
