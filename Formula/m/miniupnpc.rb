class Miniupnpc < Formula
  desc "UPnP IGD client library and daemon"
  homepage "http://miniupnp.free.fr/"
  url "https://github.com/miniupnp/miniupnp/releases/download/miniupnpc_2_3_5/miniupnpc-2.3.5.tar.gz"
  sha256 "b9a1e57233216c5f62572de6d628e73e910f50cdb71e9c0eb89b169ce154d256"
  license "BSD-3-Clause"
  compatibility_version 1
  head "https://github.com/miniupnp/miniupnp.git", branch: "master"

  livecheck do
    url :stable
    regex(/^miniupnpc[._-]v?(\d+(?:[._]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.map { |tag| tag[regex, 1]&.tr("_", ".") }
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "34862835ef422f61691863f0d4af0a80c343ba20cd615452f4163f9d0adcd10f"
  end

  deny_network_access!

  def install
    # When building from head we have to cd into the miniupnpc directory
    build_dir = build.head? ? "miniupnpc" : "."

    system "make", "-C", build_dir, "INSTALLPREFIX=#{prefix}", "install"
  end

  test do
    # `No IGD UPnP Device` on CI
    output = shell_output("#{bin}/upnpc -l 2>&1", 1)
    assert_match "No IGD UPnP Device found on the network !", output

    output = shell_output("#{bin}/upnpc --help 2>&1")
    assert_match version.to_s, output
  end
end
