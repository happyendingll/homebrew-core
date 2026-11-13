class Sqlpage < Formula
  desc "Web app builder using SQL queries to create dynamic webapps quickly"
  homepage "https://sql-page.com/"
  url "https://github.com/sqlpage/SQLpage/archive/refs/tags/v0.48.0.tar.gz"
  sha256 "ec5d243878ba7675f22b3e69b6517575c3179438d9457025739e83daca7b556e"
  license "MIT"
  head "https://github.com/sqlpage/SQLpage.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "0cdd762360a88f350d969891ee15978f73eae72bef41e529fed5f1aba4f25b28"
  end

  depends_on "node" => :build
  depends_on "rust" => :build
  depends_on "unixodbc"

  allow_network_access! :test

  def fetch
    system "npm", "ci", *std_npm_args(prefix: false)
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "npm", "run", "build"
    system "cargo", "install", *std_cargo_args
  end

  test do
    port = free_port

    ENV["PORT"] = port.to_s
    pid = spawn bin/"sqlpage"

    assert_match "It works", shell_output("curl --retry-connrefused --retry 4 --silent http://localhost:#{port}")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
