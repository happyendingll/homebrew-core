class Dtools < Formula
  desc "D programming language tools"
  homepage "https://dlang.org/"
  url "https://github.com/dlang/tools/archive/refs/tags/v2.113.1.tar.gz"
  sha256 "d225f5436d3fd1bc06dbe7839e9e38f81e2510ad1a497ce4ab294800ccc42806"
  license "BSL-1.0"
  compatibility_version 1
  head "https://github.com/dlang/tools.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "cc0f23404916f2952cb56112ccc647b5451052ca85cbdd66c49ba299237dfe92"
  end

  depends_on "dub" => :build
  depends_on "ldc" => [:build, :test]

  link_overwrite "bin/ddemangle"
  link_overwrite "bin/dustmite"
  link_overwrite "bin/rdmd"

  def install
    # We only need the "public" tools, as listed at
    # https://github.com/dlang/tools/blob/master/README.md
    #
    # Skip building dman as it requires getting and building the DMD
    # and dlang.org source trees.
    tools = %w[ddemangle rdmd dustmite]
    system "dub", "add-local", buildpath

    tools.each do |tool|
      system "dub", "build", "--build=release", ":#{tool}"
      bin.install "dtools_#{tool}" => tool
    end

    man1.install "man/man1/rdmd.1"
  end

  test do
    (testpath/"hello.d").write <<~D
      import std.stdio;
      void main()
      {
        writeln("Hello world!");
      }
    D
    assert_equal "Hello world!", shell_output("#{bin}/rdmd #{testpath}/hello.d").chomp
  end
end
