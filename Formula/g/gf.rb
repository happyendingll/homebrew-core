class Gf < Formula
  desc "App development framework of Golang"
  homepage "https://goframe.org"
  url "https://github.com/gogf/gf/archive/refs/tags/v2.10.5.tar.gz"
  sha256 "00cb34258148f6991120eac5a0ca8e5cfa4231d3cbf90fdc01786f35aeead309"
  license "MIT"
  head "https://github.com/gogf/gf.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "363ebc8f4cb548f17932fc62a3c4fe43533f32cb3325ec4c729862e132c10b9d"
  end

  depends_on "go" => [:build, :test]

  deny_network_access!

  def fetch
    system "go", "mod", "download", "-C", "cmd/gf"
  end

  def install
    cd "cmd/gf" do
      system "go", "build", *std_go_args
    end
  end

  test do
    output = shell_output("#{bin}/gf --version 2>&1")
    assert_match "v#{version}\nWelcome to GoFrame!", output
    assert_match "GF Version(go.mod): cannot find go.mod", output

    output = shell_output("#{bin}/gf init test 2>&1")
    assert_match "you can now run \"cd test && gf run main.go\" to start your journey, enjoy!", output
  end
end
