class Fselect < Formula
  desc "Find files with SQL-like queries"
  homepage "https://fselect.rocks"
  url "https://github.com/jhspetersson/fselect/archive/refs/tags/0.10.3.tar.gz"
  sha256 "e2dc2d40c58c273a6e9efece80ad14dc05f07ad01bbafd0fba5da3ebd73464e1"
  license any_of: ["Apache-2.0", "MIT"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "7d3a09c1ca53286bd167816bc46b04d13f36dd0af319629ff0703747d1637312"
  end

  depends_on "cmake" => :build # for libz-ng-sys
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  depends_on "libgit2"

  uses_from_macos "bzip2"

  def install
    ENV["LIBGIT2_NO_VENDOR"] = "1"

    system "cargo", "install", *std_cargo_args
  end

  test do
    require "utils/linkage"

    touch testpath/"test.txt"
    cmd = "#{bin}/fselect name from . where name = '*.txt'"
    assert_match "test.txt", shell_output(cmd).chomp

    linked_libraries = [
      formula_opt_lib("libgit2")/shared_library("libgit2"),
    ]
    linked_libraries.each do |library|
      assert Utils.binary_linked_to_library?(bin/"fselect", library),
             "No linkage with #{library.basename}! Cargo is likely using a vendored version."
    end
  end
end
