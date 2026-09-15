class OsvScanner < Formula
  desc "Vulnerability scanner which uses the OSV database"
  homepage "https://google.github.io/osv-scanner/"
  url "https://github.com/google/osv-scanner/archive/refs/tags/v2.6.0.tar.gz"
  sha256 "848ead2e06aa6e6150cecc2d82b867da7636d241e50b88f0922511acdac00a00"
  license "Apache-2.0"
  head "https://github.com/google/osv-scanner.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "ef635021a009a31bc8f3b830b97249305fe055cef6138b2d90ee90d59e6745c7"
  end

  depends_on "go" => [:build, :test]

  # `test do` block queries api.osv.dev
  deny_network_access! [:build, :postinstall]

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/osv-scanner"
  end

  test do
    (testpath/"go.mod").write <<~GOMOD
      module my-library

      require (
        github.com/BurntSushi/toml v1.0.0
      )
    GOMOD

    scan_output = shell_output("#{bin}/osv-scanner --lockfile #{testpath}/go.mod")
    assert_match "Scanned #{testpath}/go.mod file and found 1 package", scan_output
  end
end
