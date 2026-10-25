class Dagu < Formula
  desc "Lightweight and powerful workflow engine"
  homepage "https://dagu.sh"
  url "https://github.com/dagucloud/dagu/archive/refs/tags/v2.22.3.tar.gz"
  sha256 "c8e7d6644c4a4dee5fcc582228edfbc2ec8a2e845f564c76b5f6a8a754507217"
  license "GPL-3.0-only"
  head "https://github.com/dagucloud/dagu.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "94d8072f6e8d2d1a3f5b4b78a80dd53145a59f68433cc457f61a100fa99bd27f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "93882ff743a6f7d0c3ba3cc4b05caa14f512a07a482b53891b1b12119e9e2e6c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "7482d4802e0866dda41fe7cad45db69913eb6473c484bd53d3a0ecca6cbda1c4"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "41f444a751134af0d723b06e04d269c8439c3a44d20fcdafbe2d424530f0aed2"
    sha256 cellar: :any,                 x86_64_linux:      "ac3c817f5f8a5d8438e93cb33a1b2f50c9328ad27aaac331921113c92b264a74"
  end

  depends_on "go" => :build
  depends_on "node" => :build
  depends_on "pnpm" => :build

  allow_network_access! :test

  def fetch
    system "pnpm", "with", "current", "--dir", "ui", "fetch", "--ignore-scripts"
    system "go", "mod", "download"
  end

  def install
    system "pnpm", "--offline", "with", "current", "--dir", "ui", "install", "--frozen-lockfile", "--ignore-scripts"
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
