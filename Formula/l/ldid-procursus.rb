class LdidProcursus < Formula
  desc "Put real or fake signatures in a Mach-O binary"
  homepage "https://github.com/ProcursusTeam/ldid"
  url "https://github.com/ProcursusTeam/ldid/archive/refs/tags/v2.1.5-procursus8.tar.gz"
  version "2.1.5-procursus8"
  sha256 "d8034f4c76c1d042e5e6984c79c5da5a0fb4c08e8d2fb20b3691ffa39d377000"
  license "AGPL-3.0-or-later"
  compatibility_version 1
  head "https://github.com/ProcursusTeam/ldid.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+-procursus\d+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "8768db6c95478173e41308303e4233fe414e9ce16f0f9daf584cd51b9b99010b"
  end

  depends_on "pkgconf" => :build
  depends_on "libplist"
  depends_on "openssl@4"

  conflicts_with "ldid", because: "ldid installs a conflicting ldid binary"

  deny_network_access!

  def install
    system "make", "install", "PREFIX=#{prefix}"
    zsh_completion.install "_ldid"
  end

  test do
    (testpath/"test.xml").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
      	<key>platform-application</key>
      	<true/>
      	<key>com.apple-private.security.no-container</key>
      	<true/>
      	<key>com.apple-private.skip-library-validation</key>
      	<true/>
      </dict>
      </plist>
    XML
    cp test_fixtures("mach/fat.dylib"), testpath
    system bin/"ldid", "-Stest.xml", "fat.dylib"
    assert_match (testpath/"test.xml").read, shell_output("#{bin}/ldid -arch x86_64 -e fat.dylib")
    assert_match version.to_s, shell_output("#{bin}/ldid 2>&1")
  end
end
