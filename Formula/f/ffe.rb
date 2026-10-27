class Ffe < Formula
  desc "Parse flat file structures and print them in different formats"
  homepage "https://github.com/igitur/ffe"
  url "https://github.com/igitur/ffe/archive/refs/tags/v0.4.1d.tar.gz"
  version "0.4.1d"
  sha256 "2a5914de7779b9021031810ccafbcb8c15d47b17662559e976b304478c3d949c"
  license "GPL-2.0-or-later"
  head "https://github.com/igitur/ffe.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "fb7b33c32e66fb864b515d9f972a74492c967f692b121913e927f87a75ffe4c6"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "texinfo" => :build
  depends_on "libgcrypt"

  deny_network_access!

  def install
    ENV.append "CFLAGS", "-std=gnu89" if DevelopmentTools.clang_build_version >= 1500
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"source").write "EArthur Guinness   25"
    (testpath/"test.rc").write <<~EOS
      structure personel_fix {
        type fixed
        record employee {
          id 1 E
          field EmpType 1
          field FirstName 7
          field LastName  11
          field Age 2
        }
      }
      output default {
        record_header "<tr>"
        data "<td>%t</td>"
        record_trailer "</tr>"
        no-data-print no
      }
    EOS

    system bin/"ffe", "-c", "test.rc", "source"
  end
end
