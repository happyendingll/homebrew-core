class KubectlKlock < Formula
  desc "Kubectl plugin to render watch output in a more readable fashion"
  homepage "https://github.com/applejag/kubectl-klock"
  url "https://github.com/applejag/kubectl-klock/archive/refs/tags/v0.9.3.tar.gz"
  sha256 "98f28a0d32a5cd0bd07f6d4dc12fd8f1ef069dba176f222540b31e3689366719"
  license all_of: ["GPL-3.0-or-later", "CC0-1.0"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "418a5c90cc5f59ce25c695234ec12af6cc7591ed2b44724137c0d1d533849821"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
    generate_completions_from_executable(bin/"kubectl-klock", shell_parameter_format: :cobra)
    bin.install "bin/kubectl_complete-klock"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kubectl-klock --version")

    output = ""
    PTY.spawn "#{bin}/kubectl-klock pods" do |r, _w, pid|
      sleep 1
      Process.kill("TERM", pid)
      begin
        r.each_line { |line| output += line }
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      end
    end
    assert_match "connect: connection refused", output
  end
end
