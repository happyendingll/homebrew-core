class Garden < Formula
  desc "Grow and cultivate collections of Git trees"
  homepage "https://garden-rs.gitlab.io"
  url "https://github.com/garden-rs/garden/archive/refs/tags/v2.8.0.tar.gz"
  sha256 "398bab121145f71656d0349f99ed77d52534021414818fbd3bb6e81dcd311111"
  license "MIT"
  head "https://github.com/garden-rs/garden.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "3415f715561e1ee086bf16ab146e7bfd4f2570408a68e1abde5dcf4c187da320"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
    system "cargo", "install", *std_cargo_args(path: "gui")
  end

  test do
    (testpath/"garden.yaml").write <<~YAML
      trees:
        current:
          path: ${GARDEN_CONFIG_DIR}
          commands:
            test: touch ${TREE_NAME}
      commands:
        test: touch ${filename}
      variables:
        filename: $ echo output
    YAML
    system bin/"garden", "-vv", "test", "current"
    assert_path_exists testpath/"current"
    assert_path_exists testpath/"output"
  end
end
