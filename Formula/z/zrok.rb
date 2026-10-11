class Zrok < Formula
  desc "Geo-scale, next-generation sharing platform built on top of OpenZiti"
  homepage "https://zrok.io"
  url "https://github.com/openziti/zrok/releases/download/v2.0.8/source-v2.0.8.tar.gz"
  sha256 "f55ee736a36599add0d7a21c9d37454a39beaa2baebaacdd797f43d347ca693d"
  # The main license is Apache-2.0. ACKNOWLEDGEMENTS.md lists licenses for parts of code
  license all_of: ["Apache-2.0", "BSD-3-Clause", "MIT"]
  head "https://github.com/openziti/zrok.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "5e2deb35ffe74284e99b678097d5f35a352c24311e333500fe930b27a4924bdd"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  deny_network_access!

  def ui_dirs = ["ui", "agent/agentUi"]

  def fetch
    ui_dirs.each do |ui_dir|
      cd ui_dir do
        system "npm", "install", *std_npm_args(prefix: false)
      end
    end
    system "go", "mod", "download"
  end

  def install
    ui_dirs.each do |ui_dir|
      cd ui_dir do
        system "npm", "run", "build"
      end
    end

    # Workaround to avoid patchelf corruption when cgo is required (for go-sqlite3)
    if OS.linux? && Hardware::CPU.arch == :arm64
      ENV["CGO_ENABLED"] = "1"
      ENV["GO_EXTLINK_ENABLED"] = "1"
      ENV.append "GOFLAGS", "-buildmode=pie"
    end

    ldflags = %W[
      -X github.com/openziti/zrok/v2/build.Version=v#{version}
      -X github.com/openziti/zrok/v2/build.Hash=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/zrok2"

    generate_completions_from_executable(bin/"zrok", shell_parameter_format: :cobra)
  end

  test do
    (testpath/"ctrl.yml").write <<~YAML
      v: 4
      maintenance:
        registration:
          expiration_timeout:           24h
          check_frequency:              1h
          batch_limit:                  500
        reset_password:
          expiration_timeout:           15m
          check_frequency:              15m
          batch_limit:                  500
    YAML

    version_output = shell_output("#{bin}/zrok version")
    assert_match(/\bv#{version}\b/, version_output)
    assert_match(/[[a-f0-9]{40}]/, version_output)

    status_output = shell_output("#{bin}/zrok controller validate #{testpath}/ctrl.yml 2>&1")
    assert_match(/expiration_timeout\s+:\s+24h0m0s/, status_output)
  end
end
