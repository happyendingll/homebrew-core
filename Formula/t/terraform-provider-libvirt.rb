class TerraformProviderLibvirt < Formula
  desc "Terraform provisioning with Linux KVM using libvirt"
  homepage "https://github.com/dmacvicar/terraform-provider-libvirt"
  url "https://github.com/dmacvicar/terraform-provider-libvirt/archive/refs/tags/v0.9.9.tar.gz"
  sha256 "ac862a6eb4a9aeac94bf61a3f1eea6f1a3854b01bc75ad2f0be19847b9dcee7a"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "4b043eb89e9a28b15d1b9bb6b02ea319ddfa554b9ce61af1088729c3eaa4ff00"
  end

  depends_on "go" => :build
  depends_on "pkgconf" => :build

  depends_on "libvirt"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "run", "./internal/codegen"
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end

  test do
    assert_match(/This binary is a plugin/, shell_output("#{bin}/terraform-provider-libvirt 2>&1", 1))
  end
end
