class Labctl < Formula
  desc "CLI tool for interacting with iximiuz labs and playgrounds"
  homepage "https://labs.iximiuz.com/playgrounds"
  url "https://github.com/iximiuz/labctl/archive/refs/tags/v0.1.115.tar.gz"
  sha256 "448334360446b735d3c73a3df9bee10f4bbbfa55277e65afe2ccd8e1414f8b3e"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e5e14c3619c9c173cb67f5613f433218929933dfd64d593b262e3b7c4e7ebe01"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "e5e14c3619c9c173cb67f5613f433218929933dfd64d593b262e3b7c4e7ebe01"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "e5e14c3619c9c173cb67f5613f433218929933dfd64d593b262e3b7c4e7ebe01"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "683b77cb37fa206d64e08672a993b467d16fc512dda37e0de91a8d4cddd14848"
    sha256 cellar: :any,                 x86_64_linux:      "9323fe1f6a974ab9f1a8e6a5bb36ac1bb014497fc3bd5965512756dbd32fbc44"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X main.version=#{version}
      -X main.commit=#{tap.user}
      -X main.date=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/labctl --version")

    assert_match "Not logged in.", shell_output("#{bin}/labctl auth whoami 2>&1")
    assert_match "authentication required.", shell_output("#{bin}/labctl playground list 2>&1", 1)
  end
end
