class Skip < Formula
  desc "Tool for building Swift apps for Android"
  homepage "https://skip.dev"
  url "https://github.com/skiptools/skipstone/archive/refs/tags/1.9.17.tar.gz"
  sha256 "22d33587fc3db881f012bb5690f5b13d993a738188900b62bb78013f53c8ca14"
  license "AGPL-3.0-only"
  head "https://github.com/skiptools/skipstone.git", branch: "main"

  bottle do
    sha256 arm64_golden_gate: "95a1e93a9897b90dbb57c42ba2944837b91a43bfc38c969a8c8ac8286f91aaac"
    sha256 arm64_tahoe:       "81194a5cb6aa8971fa911b059686a44403552ef340f28de2556b434e03437f59"
    sha256 arm64_sequoia:     "d7a53b0bdf33080947a4031c6895a2b3a088bec59865f3542b2d782776d4eb2a"
    sha256 arm64_linux:       "cd1fb4c0b9d018ff2fa667ee64c72068be2d2380f36c349bd60cbf74e8334f50"
    sha256 x86_64_linux:      "10bf12d5ac99424e2cd85c6adf9c3139adaeeeb75efba357b970233d41f2de0f"
  end

  depends_on "gradle"
  depends_on "openjdk"
  depends_on "swiftly"

  uses_from_macos "swift" => [:build, :test]
  uses_from_macos "curl"
  uses_from_macos "libxml2"

  on_macos do
    depends_on xcode: :build
  end

  on_linux do
    depends_on "libarchive"
    depends_on "zlib-ng-compat"
  end

  resource "skipsubmodule" do
    url "https://github.com/skiptools/skip/archive/refs/tags/1.9.17.tar.gz"
    sha256 "b74fde5de050453ab22456ca233ac3b08b5861f712abe950fef6cb68f7be8240"

    livecheck do
      formula :parent
    end
  end

  def install
    resource("skipsubmodule").stage buildpath/"skip"

    # FIXME: need to update brew as Swift 6.4.0+ doesn't use ld shim anymore
    if OS.linux?
      args = ENV["HOMEBREW_LIBRARY_PATHS"].to_s.split(":").flat_map { ["-Xlinker", "-L#{it}"] } +
             ENV["HOMEBREW_RPATH_PATHS"].to_s.split(":").flat_map { ["-Xlinker", "-rpath", "-Xlinker", it] }
    end

    system "swift", "build", "--product", "SkipRunner", *args, *std_swift_args
    bin.install ".build/release/SkipRunner" => "skip"
    generate_completions_from_executable(bin/"skip", "--generate-completion-script")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/skip version")
    system bin/"skip", "welcome"
    system bin/"skip", "init", "--no-build", "--transpiled-app", "--appid", "some.app.id", "some-app", "SomeApp"
    assert_path_exists testpath/"some-app/Package.swift"
  end
end
