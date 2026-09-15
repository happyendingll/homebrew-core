class Snakeviz < Formula
  include Language::Python::Virtualenv

  desc "Web-based viewer for Python profiler output"
  homepage "https://jiffyclub.github.io/snakeviz/"
  url "https://files.pythonhosted.org/packages/04/06/82f56563b16d33c2586ac2615a3034a83a4ff1969b84c8d79339e5d07d73/snakeviz-2.2.2.tar.gz"
  sha256 "08028c6f8e34a032ff14757a38424770abb8662fb2818985aeea0d9bc13a7d83"
  license "BSD-3-Clause"
  revision 5

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "89d505688a96491a2f7cbb8b0e93c9da9e876aa7334186c277e15f7a8372f840"
  end

  depends_on "python@3.14"

  resource "tornado" do
    url "https://files.pythonhosted.org/packages/10/d3/343e5bb989d6515b1646cf3d40135d73f3d5e45339bded401b56cdac24dd/tornado-6.5.8.tar.gz"
    sha256 "9452e1b208a8bd771e2cb1f2ff564985b9b214bdebbe622793e1799e0a6bd23f"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    require "cgi"
    system bin/"snakeviz", "--version"
    system python3, "-m", "cProfile", "-o", "output.prof", "-m", "cProfile"

    port = free_port

    output_file = testpath/"output.prof"

    pid = fork do
      exec bin/"snakeviz", "--port", port.to_s, "--server", output_file
    end
    sleep 3
    output = shell_output("curl -s http://localhost:#{port}/snakeviz/#{ERB::Util.url_encode output_file}")
    assert_match "cProfile", output
  ensure
    Process.kill("HUP", pid)
  end
end
