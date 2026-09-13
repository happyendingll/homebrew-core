class Dcd < Formula
  desc "Auto-complete program for the D programming language"
  homepage "https://github.com/dlang-community/DCD"
  url "https://github.com/dlang-community/DCD.git",
      tag:      "v0.18.7",
      revision: "67feb12443738a2fea78fb8728de65b3e6bf41e4"
  license "GPL-3.0-or-later"
  head "https://github.com/dlang-community/dcd.git", branch: "master"

  bottle do
    sha256               arm64_golden_gate: "794f4b7eeea36e731b6fe05424d49fcdb5855fad7c3dba923e1069782043d040"
    sha256               arm64_tahoe:       "1e4bfa84e35419003dbc9bd24c736adf92408370ff63beec61681e2a7020c036"
    sha256               arm64_sequoia:     "71edcf7e328b75ea832345cf744d105a138782814a0ece835a08f29c8f24667b"
    sha256 cellar: :any, arm64_linux:       "acd8f5baf3010ad25143302e15ba07e33cdac71ea492f0aa60cacf51fe1e04b9"
    sha256 cellar: :any, x86_64_linux:      "03252facebc16768c471ef94400599a820d1e4e2df582147160de3343f3b91b0"
  end

  depends_on "ldc" => :build

  def install
    system "make", "ldc"
    bin.install "bin/dcd-client", "bin/dcd-server"
  end

  test do
    port = free_port

    # spawn a server, using a non-default port to avoid
    # clashes with pre-existing dcd-server instances
    server = spawn bin/"dcd-server", "-p", port.to_s
    # Give it generous time to load
    sleep 0.5
    # query the server from a client
    system bin/"dcd-client", "-q", "-p", port.to_s
  ensure
    Process.kill "TERM", server
    Process.wait server
  end
end
