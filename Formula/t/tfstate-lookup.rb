class TfstateLookup < Formula
  desc "Lookup resource attributes in tfstate"
  homepage "https://github.com/fujiwara/tfstate-lookup"
  url "https://github.com/fujiwara/tfstate-lookup/archive/refs/tags/v1.12.2.tar.gz"
  sha256 "56cbf8902e8fd071030a8f0542e6672705d8296dd0e9478bc30a36a6e4a465f5"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "ad7fe680211e9ce5e5d972fa0a9aeabd6a8bc1740ea8a6ac70d4043180bccc3f"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/tfstate-lookup"
  end

  test do
    (testpath/"terraform.tfstate").write <<~JSON
      {
        "version": 4,
        "terraform_version": "1.7.2",
        "resources": []
      }
    JSON

    output = shell_output("#{bin}/tfstate-lookup -dump")
    assert_match "{}", output
  end
end
