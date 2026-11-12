class OsvScanner < Formula
  desc "Vulnerability scanner which uses the OSV database"
  homepage "https://google.github.io/osv-scanner/"
  url "https://github.com/google/osv-scanner/archive/refs/tags/v2.7.1.tar.gz"
  sha256 "35472c072bca6571df8019843c3d2c2c7379160cc2c32fa1fe4c68f86cdd7704"
  license "Apache-2.0"
  head "https://github.com/google/osv-scanner.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "dfa6a942f359a52847bae80d5a7c80992dd43e195a31e00ee8649e604ab6dcbd"
  end

  depends_on "go" => :build

  # Avoid opening the host filesystem root during sandboxed source scans.
  patch do
    url "https://github.com/google/osv-scanner/commit/3acb3df177c53aa6be3e3a611608ed2b405a2bbc.patch?full_index=1"
    sha256 "5336c703db656024d968a5990f55a3ae277e861baf54e0688d25d090107dfc30"
    type :unofficial
    resolves "https://github.com/google/osv-scanner/pull/3269"
  end

  # `test do` block queries api.osv.dev
  allow_network_access! :test

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

    output = shell_output("#{bin}/osv-scanner scan source --no-call-analysis=go --format=json " \
                          "--all-packages --lockfile=#{testpath}/go.mod")
    packages = JSON.parse(output).fetch("results").flat_map { |result| result.fetch("packages") }
    assert_equal [{ "name" => "github.com/BurntSushi/toml", "version" => "1.0.0", "ecosystem" => "Go" }],
                 packages.map { |package| package.fetch("package").slice("name", "version", "ecosystem") }
  end
end
