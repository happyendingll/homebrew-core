class Skillshare < Formula
  desc "Sync skills across AI CLI tools"
  homepage "https://skillshare.runkids.cc"
  url "https://github.com/runkids/skillshare/archive/refs/tags/v0.24.4.tar.gz"
  sha256 "bc065de72b7361ceadb23d78f0c34eaf7fd11a8129c7128553e08bbf9261cc3b"
  license "MIT"
  head "https://github.com/runkids/skillshare.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "fdcd8ff268c53c54307aae13bd21aa0268eee43ac02223f3cc72693ae4e27ca1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "fdcd8ff268c53c54307aae13bd21aa0268eee43ac02223f3cc72693ae4e27ca1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "fdcd8ff268c53c54307aae13bd21aa0268eee43ac02223f3cc72693ae4e27ca1"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "5caffa07b172e81855de69ccfb193b67e206392c45b9525695969a84c2be7df7"
    sha256 cellar: :any,                 x86_64_linux:      "c13736c3857e004e477e7715d74d66ea6068fb3bf896bf8b96e188f18274515f"
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
