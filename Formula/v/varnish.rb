class Varnish < Formula
  desc "High-performance HTTP accelerator"
  homepage "https://www.varnish-cache.org/"
  url "https://github.com/varnish/varnish/releases/download/varnish-9.1.0/varnish-9.1.0.tar.gz"
  sha256 "fe615fa024c801d12928e7eea0e822ba93ab625a585841143c36ae02d5bcc37a"
  license "BSD-2-Clause"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 arm64_golden_gate: "e18f372af78c521f950d5285634518af0bebb6f73892efc812f5d380034edcf8"
    sha256 arm64_tahoe:       "1acc0316fd557891df55e490bd420fb8fc86427805a79454b1c81ba24a2b3dcb"
    sha256 arm64_sequoia:     "adc8484475ac3b533c688fc7b5ad556f09959e30eda675905b95d5e324aa2b50"
    sha256 arm64_linux:       "bfb1cf19db896f3bf0aad26ffbf897c833452385816a57c69ab0976e13278d7e"
    sha256 x86_64_linux:      "e9d6853821625c8394fd0b8dc23e899b893d166396bdeeda650b85835aa06737"
  end

  depends_on "docutils" => :build
  depends_on "graphviz" => :build
  depends_on "pkgconf" => :build
  depends_on "sphinx-doc" => :build
  depends_on "openssl@3"
  depends_on "pcre2"

  uses_from_macos "python" => :build
  uses_from_macos "libedit"
  uses_from_macos "ncurses"

  def install
    system "./configure", "--localstatedir=#{var}", *std_configure_args

    # flags to set the paths used by varnishd to load VMODs and VCL,
    # pointing to the ${HOMEBREW_PREFIX}/ shared structure so other packages
    # can install VMODs and VCL.
    ENV.append_to_cflags "-DVARNISH_VMOD_DIR='\"#{HOMEBREW_PREFIX}/lib/varnish/vmods\"'"
    ENV.append_to_cflags "-DVARNISH_VCL_DIR='\"#{pkgetc}:#{HOMEBREW_PREFIX}/share/varnish/vcl\"'"

    # Fix missing pthread symbols on Linux
    ENV.append_to_cflags "-pthread" if OS.linux?

    system "make", "install", "CFLAGS=#{ENV.cflags}"

    (etc/"varnish").install "etc/example.vcl" => "default.vcl"

    (pkgshare/"tests").install buildpath.glob("bin/vinyltest/tests/*.vtc")
    (pkgshare/"tests/vmod").install buildpath.glob("vmod/tests/*.vtc")
  end

  service do
    run [opt_sbin/"varnishd", "-n", var/"varnish", "-f", etc/"varnish/default.vcl", "-s", "malloc,1G", "-T",
         "127.0.0.1:2000", "-a", "127.0.0.1:8080", "-F"]
    keep_alive true
    working_dir HOMEBREW_PREFIX
    log_path var/"varnish/varnish.log"
    error_log_path var/"varnish/varnish.log"
  end

  test do
    assert_match version.to_s, shell_output("#{sbin}/varnishd -V 2>&1")

    # run a subset of the varnishtest tests:
    # - b*.vtc (basic functionality)
    # - m*.vtc (VMOD modules, including loading), but skipping m00000.vtc which is known to fail
    #   but is "nothing of concern" (see varnishcache/varnish-cache#3710)
    # - u*.vtc (utilities and background processes)
    testpath = pkgshare/"tests"
    timeout_tests = [
      testpath/"m00000.vtc",
      testpath/"b00047.vtc",
      testpath/"b00084.vtc",
      testpath/"b00086.vtc",
      testpath/"u00008.vtc",
    ]

    # test suites need libvmod_debug.so, see discussions in https://github.com/varnishcache/varnish-cache/issues/4393
    debug_tests = [
      testpath/"b00040.vtc",
      testpath/"b00070.vtc",
      testpath/"b00085.vtc",
      testpath/"b00092.vtc",
      testpath/"m00019.vtc",
      testpath/"m00021.vtc",
      testpath/"m00023.vtc",
      testpath/"m00022.vtc",
      testpath/"b00060.vtc",
      testpath/"m00025.vtc",
      testpath/"m00027.vtc",
      testpath/"m00048.vtc",
      testpath/"m00049.vtc",
      testpath/"m00050.vtc",
      testpath/"m00054.vtc",
      testpath/"m00053.vtc",
      testpath/"m00051.vtc",
      testpath/"m00052.vtc",
      testpath/"m00059.vtc",
      testpath/"m00060.vtc",
      testpath/"m00061.vtc",
    ]
    tests = testpath.glob("[bmu]*.vtc") - timeout_tests - debug_tests
    # -j: run the tests (using up to half the cores available)
    # -q: only report test failures
    # varnishtest will exit early if a test fails (use -k to continue and find all failures)
    system bin/"varnishtest", "-j", [Hardware::CPU.cores / 2, 1].max, "-q", *tests
  end
end
