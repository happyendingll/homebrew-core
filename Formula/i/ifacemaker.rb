class Ifacemaker < Formula
  desc "Generate interfaces from structure methods"
  homepage "https://github.com/vburenin/ifacemaker"
  url "https://github.com/vburenin/ifacemaker/archive/refs/tags/v1.5.0.tar.gz"
  sha256 "55e0dfc64213827ee984048634cf4af29e96f02a839542f719c807fb6a204473"
  license "Apache-2.0"
  head "https://github.com/vburenin/ifacemaker.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "b9e204b3ca539c2e938a20661d77f1f69e8ed086bece229f6fc4292b2ecb2dc8"
  end

  depends_on "go"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args
  end

  test do
    (testpath/"human.go").write <<~GO
      package main

      type Human struct {
        name string
      }

      // Returns the name of our Human.
      func (h *Human) GetName() string {
        return h.name
      }
    GO

    output = shell_output("#{bin}/ifacemaker -f human.go -s Human -i HumanIface -p humantest " \
                          "-y \"HumanIface makes human interaction easy\" " \
                          "-c \"DONT EDIT: Auto generated\"")
    assert_match "type HumanIface interface", output
  end
end
