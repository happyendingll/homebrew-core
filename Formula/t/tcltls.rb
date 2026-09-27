class Tcltls < Formula
  desc "OpenSSL extension to Tcl"
  homepage "https://core.tcl-lang.org/tcltls/home"
  url "https://core.tcl-lang.org/tcltls/uv/tcltls2.0.1.tar.gz"
  sha256 "afffeb5de1978f47745db4804c1dfdcd6605ceac32e324fe8bbe49843de0baae"
  license "TCL"

  livecheck do
    url "https://core.tcl-lang.org/tcltls/wiki/Download"
    regex(/href=.*?tcltls[._-]?v?(\d+(?:\.\d+)+)(?:[._-]src)?\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "8e61605cec906cdeaff95307c3fc3cdbcfbbf169cb794351941e5219c9655036"
  end

  depends_on "openssl@4"
  depends_on "tcl-tk" => :no_linkage

  link_overwrite "include/tcl-tk/tls.h", "share/man/mann/tls.n.gz"

  allow_network_access! :test

  def install
    system "./configure", "--includedir=#{include}/tcl-tk",
                          "--with-openssl-dir=#{formula_opt_prefix("openssl@4")}",
                          "--with-tcl=#{formula_opt_lib("tcl-tk")}",
                          "--with-tclinclude=#{formula_opt_include("tcl-tk")}/tcl-tk",
                          *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.tcl").write <<~TCL
      package require tls

      set host "brew.sh"
      set port 443
      set path "/"
      set proto "http/1.1"

      set ch [::tls::socket -servername $host -request 1 -require 1 -alpn [list [string tolower $proto]] $host $port]
      chan configure $ch -blocking 1 -buffering line -buffersize 16384 -encoding utf-8 -translation {auto crlf}

      ::tls::handshake $ch
      after 1000

      puts $ch [format "GET %s %s" $path [string toupper $proto]]
      puts $ch [format "User-Agent: Mozilla/4.0 (compatible; %s)" $::tcl_platform(os)]
      puts $ch [format "Host: %s" $host]
      puts $ch [format "Connection: close"]
      puts $ch ""
      flush $ch
      after 1000

      while {1} {
        set line [gets $ch]
        if {!([string length $line] == 0 && [eof $ch])} {
          puts $line
        } elseif {[eof $ch]} {
          close $ch
          break
        }
      }
    TCL
    assert_match "The Package Manager for Everywhere", shell_output("#{formula_opt_bin("tcl-tk")}/tclsh test.tcl")
  end
end
