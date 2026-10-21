class Klog < Formula
  desc "Command-line tool for time tracking in a human-readable, plain-text file format"
  homepage "https://klog.jotaen.net"
  url "https://github.com/jotaen/klog/archive/refs/tags/v7.2.tar.gz"
  sha256 "a11f6eb447103d9f77e02cdb37ea7fe77910835c1786f45b1760252e86672317"
  license "MIT"
  head "https://github.com/jotaen/klog.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "e6e58314de5352ec8a3223e8907c54692b448983ebe83857394400c273d81911"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # The commit variable only displays 7 characters, so we can't use #{tap.user} or "Homebrew".
    ldflags = %W[
      -X main.BinaryVersion=v#{version}
      -X main.BinaryBuildHash=brew
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/klog version --no-check --quiet")

    (testpath/"test.klg").write <<~EOS
      2018-03-24
      First day at my new job
          8:30 - 17:00
          -45m Lunch break
    EOS

    assert_match "Total: 7h45m", shell_output("#{bin}/klog total --no-style #{testpath}/test.klg")
  end
end
