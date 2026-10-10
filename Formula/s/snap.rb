class Snap < Formula
  desc "Tool to work with .snap files"
  homepage "https://snapcraft.io/"
  url "https://github.com/canonical/snapd/releases/download/2.78/snapd_2.78.vendor.tar.xz"
  sha256 "197d5e5870ae7f3681276cea37339d5ee528ddfaf47f53509f858fdad46e4aed"
  license "GPL-3.0-only"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "ed3a95f0b308f4e1c70e9ff1a4a0b299c83732b99c5ffdb8123cd809fd89cf2e"
  end

  depends_on "go" => :build
  depends_on "squashfs"

  deny_network_access!

  def fetch
    work_dir = File.directory?("snapd-#{version}") ? "snapd-#{version}" : "."
    system "go", "mod", "download", "-C", work_dir
  end

  def install
    # 2.77's vendor tarball wraps the source in an extra directory, unlike the packing scripts
    work_dir = File.directory?("snapd-#{version}") ? "snapd-#{version}" : "."

    cd work_dir do
      # TODO: Drop when a release tarball ships a `vendor` synced with `go.mod`.
      inreplace "mkversion.sh", "MOD=-mod=vendor", "MOD=-mod=mod"

      system "./mkversion.sh", version.to_s
      tags = OS.mac? ? "nosecboot" : ""

      system "go", "build", "-mod=mod", *std_go_args(tags:), "./cmd/snapd"

      bash_completion.install "data/completion/bash/snap"
      zsh_completion.install "data/completion/zsh/_snap"
    end

    (man8/"snap.8").write Utils.safe_popen_read(bin/"snap", "help", "--man")
  end

  test do
    (testpath/"pkg/meta").mkpath
    (testpath/"pkg/meta/snap.yaml").write <<~YAML
      name: test-snap
      version: 1.0.0
      summary: simple summary
      description: short description
    YAML
    system bin/"snap", "pack", "pkg"
    system bin/"snap", "version"
  end
end
