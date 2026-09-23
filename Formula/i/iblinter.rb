class Iblinter < Formula
  desc "Linter tool for Interface Builder"
  homepage "https://github.com/IBDecodable/IBLinter"
  url "https://github.com/IBDecodable/IBLinter/archive/refs/tags/0.5.0.tar.gz"
  sha256 "d1aafdca18bc81205ef30a2ee59f33513061b20184f0f51436531cec4a6f7170"
  license "MIT"
  revision 2
  head "https://github.com/IBDecodable/IBLinter.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "0fc8911a173f30af8c8f9fc0cd1afc49d9956d0c25c0e518ad8c3afe8d468e7a"
  end

  uses_from_macos "swift"

  on_macos do
    depends_on xcode: ["10.2", :build]
  end

  # Fetch a copy of SourceKitten in order to fix build with newer Swift.
  # TODO: remove when fixed: https://github.com/IBDecodable/IBLinter/issues/189
  resource "SourceKitten" do
    # https://github.com/IBDecodable/IBLinter/blob/0.5.0/Package.resolved#L41-L47
    url "https://github.com/jpsim/SourceKitten.git",
        tag:      "0.29.0",
        revision: "77a4dbbb477a8110eb8765e3c44c70fb4929098f"

    # Backport of import from HEAD
    patch :DATA
  end

  deny_network_access!

  def fetch
    (buildpath/"SourceKitten").install resource("SourceKitten")
    system "swift", "package", "--disable-sandbox", "edit", "SourceKitten", "--path", buildpath/"SourceKitten"
    system "swift", "package", "--disable-sandbox", "resolve"
  end

  def install
    args = ["--disable-sandbox", "--configuration", "release"]

    system "swift", "build", *args
    bin.install ".build/release/iblinter"
  end

  test do
    # Test by showing the help scree
    system bin/"iblinter", "help"

    # Test by linting file
    (testpath/".iblinter.yml").write <<~YAML
      ignore_cache: true
      enabled_rules: [ambiguous]
    YAML

    (testpath/"Test.xib").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <document type="com.apple.InterfaceBuilder3.CocoaTouch.XIB" version="3.0" toolsVersion="14113" targetRuntime="iOS.CocoaTouch">
        <objects>
          <view key="view" id="iGg-Eg-h0O" ambiguous="YES">
            <rect key="frame" x="0.0" y="0.0" width="375" height="667"/>
          </view>
        </objects>
      </document>
    XML

    assert_match "#{testpath}/Test.xib:0:0: error: UIView (iGg-Eg-h0O) has ambiguous constraints",
                 shell_output("#{bin}/iblinter lint --config #{testpath}/.iblinter.yml --path #{testpath}", 2).chomp
  end
end

__END__
diff --git a/Source/SourceKittenFramework/SwiftDocs.swift b/Source/SourceKittenFramework/SwiftDocs.swift
index 1d2473c..70de287 100644
--- a/Source/SourceKittenFramework/SwiftDocs.swift
+++ b/Source/SourceKittenFramework/SwiftDocs.swift
@@ -10,6 +10,14 @@
 import SourceKit
 #endif

+#if os(Linux)
+import Glibc
+#elseif os(Windows)
+import CRT
+#else
+import Darwin
+#endif
+
 /// Represents docs for a Swift file.
 public struct SwiftDocs {
     /// Documented File.
