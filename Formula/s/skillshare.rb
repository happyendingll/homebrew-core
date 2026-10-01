class Skillshare < Formula
  desc "Sync skills across AI CLI tools"
  homepage "https://skillshare.runkids.cc"
  url "https://github.com/runkids/skillshare/archive/refs/tags/v0.23.1.tar.gz"
  sha256 "72153f3bf347e3fcfc495847129a07931edaf742747c0aebfc988b2b188b1a02"
  license "MIT"
  head "https://github.com/runkids/skillshare.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "7ca20dc9f6d2ecacaa31355931e0ac945b23f8e3608eb5c6a516beec13cabc7f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "7ca20dc9f6d2ecacaa31355931e0ac945b23f8e3608eb5c6a516beec13cabc7f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "7ca20dc9f6d2ecacaa31355931e0ac945b23f8e3608eb5c6a516beec13cabc7f"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "1dc50de12928b72b91e33e888d9a42e0bea35da06404f7ae9b9df431971cf0a8"
    sha256 cellar: :any,                 x86_64_linux:      "3cdce3471b58762dc24d29522c39ead83035d7fc94d0d7f06a115c44db8726b8"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Avoid building web UI
    ui_path = "internal/server/dist"
    mkdir_p ui_path
    (buildpath/"#{ui_path}/index.html").write "<!DOCTYPE html><html><body><h1>UI not built</h1></body></html>"

    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/skillshare"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/skillshare version")

    assert_match "config not found", shell_output("#{bin}/skillshare sync 2>&1", 1)
  end
end
