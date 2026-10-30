class Goimapnotify < Formula
  desc "Execute scripts on IMAP mailbox changes using IDLE"
  homepage "https://gitlab.com/shackra/goimapnotify"
  url "https://gitlab.com/shackra/goimapnotify/-/archive/2.6.0/goimapnotify-2.6.0.tar.bz2"
  sha256 "9d51636d8f546d3fd2c85284800d5491b0919eecdb110092431e7ca15b771516"
  license "GPL-3.0-or-later"
  head "https://gitlab.com/shackra/goimapnotify.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "1f9a734cfd3d79b4ca7b57f716ad72d798395721e5a0819bdaf8d8da6c280d91"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.gittag=#{version}"), "./cmd/goimapnotify"
  end

  service do
    run [opt_bin/"goimapnotify"]
    keep_alive true
    log_path var/"log/goimapnotify.log"
    error_log_path var/"log/goimapnotify.log"
  end

  test do
    (testpath/"config.yml").write <<~YAML
      configurations:
        - username: test@example.com
    YAML

    output = shell_output("#{bin}/goimapnotify -conf #{testpath}/config.yml 2>&1", 1)
    assert_match "tag #{version}", output
    assert_match "empty or have invalid configuration format", output
  end
end
