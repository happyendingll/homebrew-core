class Bashka < Formula
  desc "Static verification of installation bash scripts"
  homepage "https://github.com/dmtrKovalenko/bashka"
  url "https://github.com/dmtrKovalenko/bashka/archive/refs/tags/v0.12.0.tar.gz"
  sha256 "352436b9932fb98ab5aacf7344ef483220309eccd43886ed51ed06c81eba48d1"
  license "MIT"
  head "https://github.com/dmtrKovalenko/bashka.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "364b4a965549f31058f504ad738432fb84f9af97825efb1103bef747378d47d5"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
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
