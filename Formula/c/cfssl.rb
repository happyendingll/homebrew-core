class Cfssl < Formula
  desc "CloudFlare's PKI toolkit"
  homepage "https://cfssl.org/"
  url "https://github.com/cloudflare/cfssl/archive/refs/tags/v1.7.0.tar.gz"
  sha256 "8ab0c1a01f89efd9265a12bd0500beffbd520bacbee02a4476a4f5122fe49ae2"
  license "BSD-2-Clause"
  head "https://github.com/cloudflare/cfssl.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "32ee5680dc08a890e86b6fcdea51ccf4796663cab0e204fceb74ed671b7c489a"
  end

  depends_on "go" => :build
  depends_on "libtool"

  deny_network_access!

  def install
    ldflags = "-X github.com/cloudflare/cfssl/cli/version.version=#{version}"

    (buildpath/"cmd").each_child(false) do |cmd|
      system "go", "build", *std_go_args(ldflags:, output: bin/cmd), "./cmd/#{cmd}"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cfssl version")
    assert_match version.to_s, shell_output("#{bin}/cfssljson --version")

    (testpath/"request.json").write <<~JSON
      {
        "CN" : "Your Certificate Authority",
        "hosts" : [],
        "key" : {
          "algo" : "rsa",
          "size" : 4096
        },
        "names" : [
          {
            "C" : "US",
            "ST" : "Your State",
            "L" : "Your City",
            "O" : "Your Organization",
            "OU" : "Your Certificate Authority"
          }
        ]
      }
    JSON
    response_json = shell_output("#{bin}/cfssl genkey -initca request.json")
    response = JSON.parse(response_json)
    assert_match(/^-----BEGIN CERTIFICATE-----.*/, response["cert"])
    assert_match(/.*-----END CERTIFICATE-----$/, response["cert"])
    assert_match(/^-----BEGIN RSA PRIVATE KEY-----.*/, response["key"])
    assert_match(/.*-----END RSA PRIVATE KEY-----$/, response["key"])
  end
end
