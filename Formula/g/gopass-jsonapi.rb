class GopassJsonapi < Formula
  desc "Gopass Browser Bindings"
  homepage "https://github.com/gopasspw/gopass-jsonapi"
  url "https://github.com/gopasspw/gopass-jsonapi/archive/refs/tags/v1.17.4.tar.gz"
  sha256 "5cc12a3894a60fc3b0233344636638fcb04a0e834912247160e333878a60e37f"
  license "MIT"
  head "https://github.com/gopasspw/gopass-jsonapi.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "ec8b5fe284b7f1a751e6bb9707796023a0c524fba0fd7204ef86a3a511d16303"
  end

  depends_on "go" => :build
  depends_on "gopass"

  on_macos do
    depends_on macos: :sonoma # for SCScreenshotManager
  end

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end

  test do
    (testpath/"batch.gpg").write <<~GPG
      Key-Type: RSA
      Key-Length: 2048
      Subkey-Type: RSA
      Subkey-Length: 2048
      Name-Real: Testing
      Name-Email: testing@foo.bar
      Expire-Date: 1d
      %no-protection
      %commit
    GPG

    begin
      system formula_opt_bin("gnupg")/"gpg", "--batch", "--gen-key", "batch.gpg"

      system formula_opt_bin("gopass")/"gopass", "init", "--path", testpath, "noop", "testing@foo.bar"
      system formula_opt_bin("gopass")/"gopass", "generate", "Email/other@foo.bar", "15"
    ensure
      system formula_opt_bin("gnupg")/"gpgconf", "--kill", "gpg-agent"
      system formula_opt_bin("gnupg")/"gpgconf", "--homedir", "keyrings/live",
                                                 "--kill", "gpg-agent"
    end

    assert_match(/^gopass-jsonapi version #{version}$/, shell_output("#{bin}/gopass-jsonapi --version"))

    msg = '{"type": "query", "query": "foo.bar"}'
    assert_match "Email/other@foo.bar",
      pipe_output("#{bin}/gopass-jsonapi listen", "#{[msg.length].pack("L<")}#{msg}")
  end
end
