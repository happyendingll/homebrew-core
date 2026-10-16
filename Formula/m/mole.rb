class Mole < Formula
  desc "Deep clean and optimize your Mac"
  homepage "https://mole.fit"
  url "https://github.com/tw93/Mole/archive/refs/tags/V1.60.0.tar.gz"
  sha256 "d4cd0e1e0aa9a2286ad040d0460891ba321da6bf78de482ea876facc13ab2b1c"
  license "GPL-3.0-or-later"
  head "https://github.com/tw93/Mole.git", branch: "main"

  # There exists a version like `vx.y.z-windows`
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  no_autobump! because: :bumped_by_upstream

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "5bf55b92742a67bed3d66649a49e04c9b9e06fde4e49a6994b9350f3f9d6f483"
  end

  depends_on "go" => :build
  depends_on :macos

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Remove prebuilt binaries
    buildpath.glob("bin/*-go").map(&:unlink)

    ldflags = "-X main.Version=#{version} -X main.BuildTime=#{time.iso8601}"
    %w[analyze status].each do |cmd|
      system "go", "build", *std_go_args(ldflags:, output: buildpath/"bin/#{cmd}-go"), "./cmd/#{cmd}"
    end

    libexec.install "mole", "bin", "lib"
    bin.install_symlink libexec/"mole"
    bin.install_symlink bin/"mole" => "mo"

    generate_completions_from_executable(bin/"mole", "completion")
  end

  test do
    # Point simctl at the CLT so the sandboxed Xcode simulator probes are skipped
    ENV["DEVELOPER_DIR"] = "/Library/Developer/CommandLineTools"
    assert_match version.to_s, shell_output("#{bin}/mole --version")
    output = shell_output("#{bin}/mole clean --dry-run 2>&1")
    assert_match "Dry run complete - no changes made", output
  end
end
