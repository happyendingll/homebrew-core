class Par2 < Formula
  desc "Parchive: Parity Archive Volume Set for data recovery"
  homepage "https://parchive.github.io"
  url "https://github.com/Parchive/par2cmdline/releases/download/v1.4.0/par2cmdline-1.4.0.tar.bz2"
  sha256 "269aff9d49c6a0c0d1c394300d35c36229764588f56faad5850eaf36c7a298dc"
  license "GPL-2.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "7355e56625f425afcd3e307f011c642afe11aa2e7b5b32de8df4168f4e9ad954"
  end

  on_macos do
    depends_on "libomp"
  end

  def install
    if OS.mac?
      libomp = Formula["libomp"]
      ENV.append_to_cflags "-Xpreprocessor -fopenmp -I#{libomp.opt_include} -L#{libomp.opt_lib} -lomp"
    end

    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    # Protect a file with par2.
    test_file = testpath/"some-file"
    File.write(test_file, "file contents")
    system bin/"par2", "create", test_file

    # "Corrupt" the file by overwriting, then ask par2 to repair it.
    File.write(test_file, "corrupted contents")
    repair_command_output = shell_output("#{bin}/par2 repair #{test_file}")

    # Verify that par2 claimed to repair the file.
    assert_match "1 file(s) exist but are damaged.", repair_command_output
    assert_match "Repair complete.", repair_command_output

    # Verify that par2 actually repaired the file.
    assert_equal "file contents", File.read(test_file)
  end
end
