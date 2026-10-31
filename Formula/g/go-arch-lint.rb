class GoArchLint < Formula
  desc "Architecture linter for Go projects"
  homepage "https://github.com/fe3dback/go-arch-lint"
  url "https://github.com/fe3dback/go-arch-lint/archive/refs/tags/v1.19.1.tar.gz"
  sha256 "b3829f82788f6f5b0b741a25936d9d1d539fc8de6b3342bd2bfa34b0eabe53c9"
  license "MIT"
  head "https://github.com/fe3dback/go-arch-lint.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "4a18e3af256343cf86c8d08c8b29b01e8480c9a0490b0ebf3bbea7288b0eccaf"
  end

  depends_on "go"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X github.com/fe3dback/go-arch-lint/internal/app.Version=#{version}")

    generate_completions_from_executable(bin/"go-arch-lint", shell_parameter_format: :cobra)
  end

  test do
    version_output = JSON.parse(shell_output("#{bin}/go-arch-lint version --json"))
    assert_equal version.to_s, version_output.dig("Payload", "LinterVersion")

    system "go", "mod", "init", "example.com/brewtest"

    (testpath/"repository/repository.go").write <<~GO
      package repository

      func Value() int { return 1 }
    GO

    (testpath/"service/service.go").write <<~GO
      package service

      import "example.com/brewtest/repository"

      func Value() int { return repository.Value() }
    GO

    (testpath/".go-arch-lint.yml").write <<~YAML
      version: 3
      components:
        service: { in: service }
        repository: { in: repository }
      deps: {}
    YAML

    output = JSON.parse(shell_output("#{bin}/go-arch-lint check --json", 1)).fetch("Payload")
    assert_empty output.fetch("ExecutionWarnings")
    assert_equal 1, output.fetch("ArchWarningsDeps").length
    warning = output.fetch("ArchWarningsDeps").first
    assert_equal "service", warning.fetch("ComponentName")
    assert_equal "example.com/brewtest/repository", warning.fetch("ResolvedImportName")

    inreplace testpath/".go-arch-lint.yml", "deps: {}", <<~YAML.chomp
      deps:
        service:
          mayDependOn: [repository]
    YAML

    output = JSON.parse(shell_output("#{bin}/go-arch-lint check --json")).fetch("Payload")
    assert_empty output.fetch("ExecutionWarnings")
    assert_equal false, output.fetch("ArchHasWarnings")
  end
end
