class K6 < Formula
  desc "Modern load testing tool, using Go and JavaScript"
  homepage "https://k6.io"
  url "https://github.com/grafana/k6/archive/refs/tags/v2.3.0.tar.gz"
  sha256 "35d0e4ce17ac3b7557f220a63bd9486f24dd63e032fbe1aed8a79326191a2097"
  license "AGPL-3.0-or-later"
  head "https://github.com/grafana/k6.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "0d39ebf0e922f20ac3d4633afb4c4704e723f8c91592a0fe919d4885e2e26525"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args

    generate_completions_from_executable(bin/"k6", shell_parameter_format: :cobra)
  end

  test do
    (testpath/"whatever.js").write <<~JS
      export default function() {
        console.log("whatever");
      }
    JS

    assert_match "whatever", shell_output("#{bin}/k6 run whatever.js 2>&1")

    assert_match version.to_s, shell_output("#{bin}/k6 version")
  end
end
