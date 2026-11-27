class Xcodegen < Formula
  desc "Generate your Xcode project from a spec file and your folder structure"
  homepage "https://github.com/yonaskolb/XcodeGen"
  url "https://github.com/yonaskolb/XcodeGen/archive/refs/tags/2.49.0.tar.gz"
  sha256 "2a94567303c5ff9a21b91c9af21ea51c681b012cfbf0d2852fb567865b310fe4"
  license "MIT"
  compatibility_version 1
  head "https://github.com/yonaskolb/XcodeGen.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "7008caa0c51788a8dae2e27a3f1c960f5d6dd97cf20ddd00a3fba843499a8a40"
  end

  depends_on xcode: ["15.3", :build]
  depends_on :macos

  uses_from_macos "swift"

  deny_network_access!

  def fetch
    # SwiftPM tries to apply its own sandbox, which cannot nest inside the
    # build sandbox; Homebrew's sandbox still confines the whole process.
    system "swift", "package", "resolve", "--disable-sandbox"
  end

  def install
    system "swift", "build", *std_swift_args
    bin.install ".build/release/#{name}"
    pkgshare.install "SettingPresets"
  end

  test do
    (testpath/"xcodegen.yml").write <<~YAML
      name: GeneratedProject
      options:
        bundleIdPrefix: com.project
      targets:
        TestProject:
          type: application
          platform: iOS
          sources: TestProject
    YAML
    (testpath/"TestProject").mkpath
    system bin/"xcodegen", "--spec", testpath/"xcodegen.yml"
    assert_path_exists testpath/"GeneratedProject.xcodeproj"
    assert_path_exists testpath/"GeneratedProject.xcodeproj/project.pbxproj"
    output = (testpath/"GeneratedProject.xcodeproj/project.pbxproj").read
    assert_match "name = TestProject", output
    assert_match "isa = PBXNativeTarget", output
  end
end
