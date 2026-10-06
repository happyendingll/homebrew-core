class Xcsift < Formula
  desc "Swift tool to parse xcodebuild output for coding agents"
  homepage "https://ldomaradzki.github.io/xcsift/"
  url "https://github.com/ldomaradzki/xcsift/archive/refs/tags/v1.5.2.tar.gz"
  sha256 "ddeeec38a96f65596dead07cf85695e34410b9d989fbd0451bbd46477e0b9e55"
  license "MIT"
  head "https://github.com/ldomaradzki/xcsift.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "78de85305681dcf6b472a0a6aba355a266c238dc27cc34da5b774dcfa2410e73"
  end

  uses_from_macos "swift" => :build, since: :sonoma

  on_macos do
    depends_on xcode: ["16.0", :build]
  end

  def install
    inreplace "Sources/xcsift/main.swift", "VERSION_PLACEHOLDER", version.to_s

    system "swift", "build", *std_swift_args
    bin.install ".build/release/xcsift"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/xcsift --version")

    output = pipe_output(bin/"xcsift", "Build succeeded")
    assert_match "status", output
    assert_match "summary", output
  end
end
