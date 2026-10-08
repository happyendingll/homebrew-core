class Cfssl < Formula
  desc "CloudFlare's PKI toolkit"
  homepage "https://cfssl.org/"
  url "https://github.com/cloudflare/cfssl/archive/refs/tags/v1.7.1.tar.gz"
  sha256 "6eb828923ad1e43efacab8dde17d86bf05c17ab97c072114a5f17d0184d55a92"
  license "BSD-2-Clause"
  head "https://github.com/cloudflare/cfssl.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "d19fd2b92af431c73bcaf3dc548d331ae8d109bf3bc0ac9e9be655477e67a2ec"
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
