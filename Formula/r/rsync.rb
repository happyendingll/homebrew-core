class Rsync < Formula
  desc "Utility that provides fast incremental file transfer"
  homepage "https://rsync.samba.org/"
  url "https://github.com/RsyncProject/rsync/releases/download/v3.5.2/rsync-3.5.2.tar.gz"
  mirror "https://rsync.samba.org/ftp/rsync/rsync-3.5.2.tar.gz"
  sha256 "a10d591825251e070f74c98df3daad195def4ed81b4a2de16169026aea33f6c8"
  license "GPL-3.0-or-later"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "3e8f94e474515f81ddd86f7d5ea6670ecd5bd14fbad8d8775a811caf7431e348"
  end

  depends_on "libidn2"
  depends_on "lz4"
  depends_on "openssl@4"
  depends_on "popt"
  depends_on "xxhash"
  depends_on "zstd"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    args = %W[
      --with-rsyncd-conf=#{etc}/rsyncd.conf
      --with-included-popt=no
      --with-included-zlib=no
      --with-rrsync=yes
      --enable-ipv6
    ]

    system "./configure", *args, *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    mkdir "a"
    mkdir "b"

    ["foo\n", "bar\n", "baz\n"].map.with_index do |s, i|
      (testpath/"a/#{i + 1}.txt").write s
    end

    system bin/"rsync", "-artv", testpath/"a/", testpath/"b/"

    (1..3).each do |i|
      assert_equal (testpath/"a/#{i}.txt").read, (testpath/"b/#{i}.txt").read
    end
  end
end
