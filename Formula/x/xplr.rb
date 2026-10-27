class Xplr < Formula
  desc "Hackable, minimal, fast TUI file explorer"
  homepage "https://xplr.dev"
  url "https://github.com/sayanarijit/xplr/archive/refs/tags/v1.2.2.tar.gz"
  sha256 "25029a01d5c849cede183ec7bccc6c8bdb4e68c8070d573b288169671dc3ee3e"
  license "MIT"
  head "https://github.com/sayanarijit/xplr.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "b37810a0a44fadf642002a8131e3edf64138fc4b1201e6fada9f4226be9fca5b"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "luajit"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", "--no-default-features", *std_cargo_args
  end

  test do
    require "utils/linkage"

    input, = Open3.popen2 "SHELL=/bin/sh script -q output.txt"
    input.puts "stty rows 80 cols 130"
    input.puts bin/"xplr"
    input.putc "q"
    input.puts "exit"

    sleep 5
    File.open(testpath/"output.txt", "r:ISO-8859-7") do |f|
      contents = f.read
      assert_match testpath.to_s, contents
    end

    assert Utils.binary_linked_to_library?(bin/"xplr",
                                formula_opt_lib("luajit")/shared_library("libluajit")),
           "No linkage with libluajit! Cargo is likely using a vendored version."
  end
end
