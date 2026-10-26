class Gastown < Formula
  desc "Multi-agent workspace manager"
  homepage "https://github.com/gastownhall/gastown"
  url "https://github.com/gastownhall/gastown/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "ddfaf8e774e9f3a281239c04592d04aee10afe621cbfa5df3e29310c9838d753"
  license "MIT"
  revision 1
  head "https://github.com/gastownhall/gastown.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "83ce507ff92dc70ddc176fea981d00fdc94b32638412e3f70334c63f39852a23"
  end

  depends_on "go" => :build
  depends_on "beads"
  depends_on "icu4c@79"

  conflicts_with "genometools", "libslax", because: "both install `gt` binaries"

  # Test binds a local port
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -s -w
      -X github.com/steveyegge/gastown/internal/cmd.Version=#{version}
      -X github.com/steveyegge/gastown/internal/cmd.Build=#{tap.user}
      -X github.com/steveyegge/gastown/internal/cmd.Commit=#{tap.user}
      -X github.com/steveyegge/gastown/internal/cmd.Branch=v#{version}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/gt"
    bin.install_symlink "gastown" => "gt"

    generate_completions_from_executable(bin/"gt", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gt version")

    system "dolt", "config", "--global", "--add", "user.name", "BrewTestBot"
    system "dolt", "config", "--global", "--add", "user.email", "BrewTestBot@test.com"

    system bin/"gt", "install", "--dolt-port", free_port.to_s
    assert_path_exists testpath/"mayor"
  end
end
