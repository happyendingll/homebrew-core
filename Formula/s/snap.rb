class Snap < Formula
  desc "Tool to work with .snap files"
  homepage "https://snapcraft.io/"
  url "https://github.com/canonical/snapd/releases/download/2.77.1/snapd_2.77.1.vendor.tar.xz"
  sha256 "10c824694cd9c9954ba7a826d245458d8fa1006d49937fe480dc9f36b57b1efc"
  license "GPL-3.0-only"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "ff990399a1cd6cfa90cd7f9b71aa3a59947f6c98986a8aa0288d424000377c2b"
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
