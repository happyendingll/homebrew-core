class Zrok < Formula
  desc "Geo-scale, next-generation sharing platform built on top of OpenZiti"
  homepage "https://zrok.io"
  url "https://github.com/openziti/zrok/releases/download/v2.0.7/source-v2.0.7.tar.gz"
  sha256 "81e49368756d83613bf7c20940af33e1943bbbf652555a97a0fb39aea28b9789"
  # The main license is Apache-2.0. ACKNOWLEDGEMENTS.md lists licenses for parts of code
  license all_of: ["Apache-2.0", "BSD-3-Clause", "MIT"]
  head "https://github.com/openziti/zrok.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "75ff145341365cd7756d33633bfc7dfe96e87ad44ab1396c9c77838952dd4191"
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
