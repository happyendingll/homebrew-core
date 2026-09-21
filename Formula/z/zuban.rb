class Zuban < Formula
  desc "Python language server and type checker, written in Rust"
  homepage "https://zubanls.com/"
  url "https://github.com/zubanls/zuban/archive/refs/tags/v0.10.0.tar.gz"
  sha256 "ef18bed5412da00667862751e16b4cf66039ae39e3618ef891f58d089fabe5c0"
  license "AGPL-3.0-only"
  head "https://github.com/zubanls/zuban.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "c75e4b988da7d52f9573664989c9458f675362d2c4ed97a0e71f3aab7643bd34"
  end

  depends_on "rust" => :build

  resource "typeshed" do
    url "https://github.com/python/typeshed/archive/aaefc85a95431045b0726b297d0ad1f4786ba1e2.tar.gz"
    version "aaefc85a95431045b0726b297d0ad1f4786ba1e2"
    sha256 "46980e94b26f9653d50ac6d1fc3d5a5f58fc90bb3f1b6517d9ca51ec381a71ae"

    livecheck do
      url "https://api.github.com/repos/zubanls/zuban/contents/third_party/typeshed?ref=v#{LATEST_VERSION}"
      strategy :json do |json|
        json["sha"]
      end
    end
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    (buildpath/"third_party/typeshed").install resource("typeshed")

    system "cargo", "install", *std_cargo_args(path: "crates/zuban")
    libexec.install (buildpath/"third_party/typeshed").children
    bin.env_script_all_files libexec/"bin", ZUBAN_TYPESHED: libexec
  end

  test do
    %w[zmypy zuban].each do |cmd|
      assert_match version.to_s, shell_output("#{bin}/#{cmd} --version")
    end

    (testpath/"t.py").write <<~PY
      def f(x: int) -> int:
        return "nope"
    PY
    out = shell_output("#{bin}/zuban check #{testpath}/t.py 2>&1", 1)
    assert_match "Incompatible return value type", out
  end
end
