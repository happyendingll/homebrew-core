class Bashka < Formula
  desc "Static verification of installation bash scripts"
  homepage "https://github.com/dmtrKovalenko/bashka"
  url "https://github.com/dmtrKovalenko/bashka/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "97758cacce997405acae16fe00b571d54dab1a7fabad2cc3795711be604e236d"
  license "MIT"
  head "https://github.com/dmtrKovalenko/bashka.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "6b56298df8adf1fc49041bd2982d0be9a186f24d140b280e9fc742e5e4047b6c"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ec6b6d651a58590ffb9c080b4ba8e39f6ad8bd1a8fda30a79bdec6e1aea175f2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c9e1ee83b3831412eed550d0ab32887339ba7d4fbb03a9a3683900b30f13f565"
    sha256 cellar: :any,                 arm64_linux:       "68f1ea3f722f77b9e358e70ccee3c86b5ce369e31b35aafef463befb79fce83d"
    sha256 cellar: :any,                 x86_64_linux:      "eaf47ee901934a4398b882577d752f2a06f5e8260bf490132ae703d4bd33ae79"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bashka --version")

    malicious = <<~BASH
      #!/usr/bin/env bash

      rm -rf /
    BASH
    empty = <<~BASH
      #!/usr/bin/env bash

      echo Hi
    BASH

    # Couldn't capture `stderr` for some reason (`2>&1` and `open3` methods didn't work).
    # Don't match output, just check the exit codes
    pipe_output("#{bin}/bashka --check", malicious, 3)
    pipe_output("#{bin}/bashka --check", empty, 1)
  end
end
