class Selene < Formula
  desc "Blazing-fast modern Lua linter"
  homepage "https://kampfkarren.github.io/selene"
  url "https://github.com/Kampfkarren/selene/archive/refs/tags/0.32.0.tar.gz"
  sha256 "cd208a4b3bae38decc9c7bb797c19615caaecf67606b3e593ca60b64d3416cd5"
  license "MPL-2.0"
  head "https://github.com/Kampfkarren/selene.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "15a67ae19b0b4a4ff57e2580a94438b9a4ff0a743e116d9a70a26217e99bee09"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "selene")
  end

  test do
    (testpath/"selene.toml").write("std = \"lua52\"")
    (testpath/"test.lua").write("print(1 / 0)")
    assert_match "warning[divide_by_zero]", shell_output("#{bin}/selene #{testpath}/test.lua", 1)
  end
end
