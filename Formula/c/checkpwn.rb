class Checkpwn < Formula
  desc "Check Have I Been Pwned and see if it's time for you to change passwords"
  homepage "https://github.com/brycx/checkpwn"
  url "https://static.crates.io/crates/checkpwn/checkpwn-0.6.3.crate"
  sha256 "8559fe476ecdbeb38d75896c817fa275ace1502cbe19e17f19bc9e81e735de2a"
  license "MIT"
  head "https://github.com/brycx/checkpwn.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "61ad3bfda76ea4cf0a6e703e5d076c68b20443c9968822615d21e0668e7a4a83"
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
    output = shell_output("#{bin}/checkpwn acc test@example.com 2>&1", 101)
    assert_match "Failed to read or parse the configuration file 'checkpwn.yml'", output
  end
end
