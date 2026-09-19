class Oauth2c < Formula
  desc "User-friendly CLI for OAuth2"
  homepage "https://github.com/SecureAuthCorp/oauth2c"
  url "https://github.com/SecureAuthCorp/oauth2c/archive/refs/tags/v1.21.0.tar.gz"
  sha256 "f03ec7b08fa9612f8196d236658f6aaa3245ddd1cab6aa94a086fe5d938a0bfc"
  license "Apache-2.0"
  head "https://github.com/SecureAuthCorp/oauth2c.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "398d47880790b213bb5d0a8823e44fd5f72eba4475697b5be82437b53cfe4074"
  end

  depends_on "go" => :build

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
