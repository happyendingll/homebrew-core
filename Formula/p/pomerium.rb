class Pomerium < Formula
  desc "Identity and context-aware access proxy"
  homepage "https://www.pomerium.com"
  url "https://github.com/pomerium/pomerium/archive/refs/tags/v0.33.5.tar.gz"
  sha256 "ffb246350427fb06b087e42bd717de6d43b254ad8aec679559f6f9544a6eab52"
  license "Apache-2.0"

  head "https://github.com/pomerium/pomerium.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "5f9705d89631d2186ca29e957c45f68cbbbc8ee6264410e494ee648842c9d58b"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "16b32a105e73d5e2a7f6732b244bae6f71d136094229f92bb830f5bfc31faf12"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c371bcbc867dcd19364d631dd1902fe1ca36fceb94b8bcae9d9da12821b9e502"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "4b613cfb5658a24b9ddda2058799ba5cfade9b9dfc347f34e77dd186733e1c1c"
    sha256 cellar: :any,                 x86_64_linux:      "533184057a11d3e5ce27f684d7bee5ad7c268fdecacfb8a3f13447c1c0070486"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  # Upstream dropped darwin x86_64 support in 0.33.0
  # https://github.com/pomerium/pomerium/pull/6141
  on_macos do
    depends_on arch: :arm64
  end

  # Fix build with Go 1.27, upstream PR ref, https://github.com/pomerium/pomerium/pull/6914
  patch do
    url "https://github.com/pomerium/pomerium/commit/73371215d5b0e0f21b5d9cf2fc909af1a179c60d.patch?full_index=1"
    sha256 "0362774a70882d2ef078977ff1c50f90c33b34a1c9db5736ea7fcb960ace7b09"
  end

  # `test do` block runs a local HTTP server
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
    system "make", "get-envoy"
    cd "ui" do
      system "npm", "ci", *std_npm_args(prefix: false)
    end
  end

  def install
    cd "ui" do
      system "npm", "--offline", "run", "build"
    end

    ldflags = %W[
      -X github.com/pomerium/pomerium/internal/version.Version=#{version}
      -X github.com/pomerium/pomerium/internal/version.GitCommit=v#{version}
      -X github.com/pomerium/pomerium/internal/version.ProjectName=pomerium
      -X github.com/pomerium/pomerium/internal/version.ProjectURL=github.com/pomerium/pomerium
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/pomerium"
  end

  service do
    run [opt_bin/"pomerium", "--config", etc/"pomerium.yaml"]
    keep_alive true
    working_dir HOMEBREW_PREFIX
    log_path var/"log/pomerium.log"
    error_log_path var/"log/pomerium.log"
  end

  test do
    port = free_port

    (testpath/"config.yaml").write <<~YAML
      insecure_server: true
      address: "127.0.0.1:#{port}"
      routes:
        - from: http://127.0.0.1:#{port}
          allow_public_unauthenticated_access: true
          response:
            status: 200
            body: "plain text"
    YAML

    pid = spawn bin/"pomerium", "--config", testpath/"config.yaml"
    sleep 10
    assert_match "OK", shell_output("curl -s http://127.0.0.1:#{port}/healthz")
    assert_match "plain text", shell_output("curl -s http://127.0.0.1:#{port}")
    assert_match version.to_s, shell_output("#{bin}/pomerium --version")
  ensure
    Process.kill("SIGINT", pid)
    Process.wait(pid)
  end
end
