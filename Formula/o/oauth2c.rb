class Oauth2c < Formula
  desc "User-friendly CLI for OAuth2"
  homepage "https://github.com/SecureAuthCorp/oauth2c"
  url "https://github.com/SecureAuthCorp/oauth2c/archive/refs/tags/v1.21.1.tar.gz"
  sha256 "8f033f91e14bddc3ff3ae2c7cdf804f4e794d94dfa0e9ef4751d9b9d9cd212c4"
  license "Apache-2.0"
  head "https://github.com/SecureAuthCorp/oauth2c.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "a0061ac01277f1efd87592a1c8566bc8541f6907e3efc6029e1c7a37c2eb134b"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser)

    generate_completions_from_executable(bin/"oauth2c", shell_parameter_format: :cobra)
  end

  test do
    assert_match "\"access_token\":",
      shell_output("#{bin}/oauth2c https://oauth2c.us.authz.cloudentity.io/oauth2c/demo " \
                   "--client-id cauktionbud6q8ftlqq0 " \
                   "--client-secret HCwQ5uuUWBRHd04ivjX5Kl0Rz8zxMOekeLtqzki0GPc " \
                   "--grant-type client_credentials " \
                   "--auth-method client_secret_basic " \
                   "--scopes introspect_tokens,revoke_tokens")
  end
end
