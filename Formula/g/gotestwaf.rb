class Gotestwaf < Formula
  desc "Tool for API and OWASP attack simulation"
  homepage "https://lab.wallarm.com/test-your-waf-before-hackers/"
  url "https://github.com/wallarm/gotestwaf/archive/refs/tags/v0.5.9.tar.gz"
  sha256 "95a504b2e456f102a9973a973c8a831ff5e6d6be735ac0b8442a77f0a4f6a4d7"
  license "MIT"
  head "https://github.com/wallarm/gotestwaf.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "ad7ca198bd6a8b0e0c149759ac419ad8282a2907086917ddbd37b4feac4958c4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ad7ca198bd6a8b0e0c149759ac419ad8282a2907086917ddbd37b4feac4958c4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "ad7ca198bd6a8b0e0c149759ac419ad8282a2907086917ddbd37b4feac4958c4"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "f837730e55f29d9d6b95b138954cb19efb0c612278f1790156c1dd8c30d72a41"
    sha256 cellar: :any,                 x86_64_linux:      "6ed7c8383ad20f88b78a29118c8bd13289daf1932f6e25a5e1a83e4a421059b6"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/wallarm/gotestwaf/internal/version.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/gotestwaf"

    pkgetc.install "config.yaml"
  end

  test do
    cp pkgetc/"config.yaml", testpath

    (testpath/"testcases/sql-injection/test.yaml").write <<~YAML
      ---
      payload:
        - '"union select -7431.1, name, @aaa from u_base--w-'
        - "'or 123.22=123.22"
        - "' waitfor delay '00:00:10'--"
        - "')) or pg_sleep(5)--"
      encoder:
        - Base64Flat
        - Url
      placeholder:
        - UrlPath
        - UrlParam
        - JsonBody
        - Header
    YAML

    output = shell_output("#{bin}/gotestwaf --noEmailReport --url https://example.com/ 2>&1", 1)
    assert_match "Try to identify WAF solution", output
    assert_match "error=\"WAF was not detected", output

    assert_match version.to_s, shell_output("#{bin}/gotestwaf --version 2>&1")
  end
end
