class Dagu < Formula
  desc "Lightweight and powerful workflow engine"
  homepage "https://dagu.sh"
  url "https://github.com/dagucloud/dagu/archive/refs/tags/v2.18.1.tar.gz"
  sha256 "e1e48f714d0708a89afde4e288fdf87fa1521614ea8ffb7fb4d9c74dc3a5313e"
  license "GPL-3.0-only"
  head "https://github.com/dagucloud/dagu.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "1c79697b9cc01d6c24a30960634eb4be069fdbb95157521ac8aea56b6aad4199"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "b4d6787aff5d06797ec2e088b029345ee83c10220b64b4581af451c444c0a9d0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "0b9c66cc5c6d6f534e11173ded2f98b9151ff8113f64d78a1a5855e6599f1be1"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "bbc0d456a499a52ab10f83898b3c9998ea75edf01541cab02b0a01b3bf61a7e3"
    sha256 cellar: :any,                 x86_64_linux:      "cc651ed27535668692fc6b3112fd24ef232e4a08a9d310ca85d9bff6424d012a"
  end

  depends_on "go" => :build
  depends_on "node" => :build
  depends_on "pnpm" => :build

  def install
    system "pnpm", "with", "current", "--dir", "ui", "install", "--frozen-lockfile", "--ignore-scripts"
    system "pnpm", "with", "current", "--dir", "ui", "run", "build"
    (buildpath/"internal/service/frontend/assets").install (buildpath/"ui/dist").children

    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd"
    generate_completions_from_executable(bin/"dagu", shell_parameter_format: :cobra)
  end

  service do
    run [opt_bin/"dagu", "start-all"]
    keep_alive true
    error_log_path var/"log/dagu.log"
    log_path var/"log/dagu.log"
    working_dir var
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dagu version 2>&1")

    (testpath/"hello.yaml").write <<~YAML
      steps:
        - name: hello
          command: echo "Hello from Dagu!"

        - name: world
          command: echo "Running step 2"
    YAML

    system bin/"dagu", "start", "hello.yaml"
    shell_output = shell_output("#{bin}/dagu status hello.yaml")
    assert_match "Result: Succeeded", shell_output
  end
end
