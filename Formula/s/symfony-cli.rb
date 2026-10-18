class SymfonyCli < Formula
  desc "Build, run, and manage Symfony applications"
  homepage "https://symfony.com/download"
  url "https://github.com/symfony-cli/symfony-cli/archive/refs/tags/v5.22.2.tar.gz"
  sha256 "5cb2eb468eb90501519395d24f2023ed19cb1b49299124eeba2516335b2510d2"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "c355d5fd25c8dd69d4651f5129a0d402c80ac6cd7c025f5f1b5e60d733ea7db8"
  end

  depends_on "go" => :build
  depends_on "composer" => :test

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X main.version=#{version}
      -X main.buildDate=#{time.iso8601}
      -X main.channel=stable
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"symfony")

    generate_completions_from_executable(bin/"symfony", "self:completion")
  end

  service do
    run ["#{opt_bin}/symfony", "local:proxy:start", "--foreground"]
    keep_alive true
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/symfony self:version")

    system bin/"symfony", "new", "--no-git", testpath/"my_project"
    assert_path_exists testpath/"my_project/symfony.lock"
  end
end
