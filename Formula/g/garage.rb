class Garage < Formula
  desc "S3 object store so reliable you can run it outside datacenters"
  homepage "https://garagehq.deuxfleurs.fr/"
  url "https://git.deuxfleurs.fr/Deuxfleurs/garage/archive/v2.4.1.tar.gz"
  sha256 "9149931f0e567a66cd96c33b6349e8f1900279ec6ae57c60bfd29d450104c553"
  license "AGPL-3.0-or-later"
  head "https://git.deuxfleurs.fr/Deuxfleurs/garage.git", branch: "main-v2"

  livecheck do
    url :head
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "016c139e0029b9ebe7085eb4260fe1b97bbe671b5874ba8fb78827916729a157"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "src/garage")
  end

  service do
    run [opt_bin/"garage", "--config", etc/"garage/config.toml", "server"]
    keep_alive true
    working_dir HOMEBREW_PREFIX
    log_path var/"log/garage.log"
    error_log_path var/"log/garage.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/garage --version")

    rpc_port = free_port
    api_port = free_port

    (testpath/"garage.toml").write <<~TOML
      data_dir = "#{testpath}/data"
      metadata_dir = "#{testpath}/metadata"

      replication_factor = 1

      rpc_bind_addr = "[::]:#{rpc_port}"
      rpc_public_addr = "127.0.0.1:#{rpc_port}"
      rpc_secret = "bb2763a7c7c397d17eb9d604c063699ab5de605cee438b7f4288e6ff1695081d"
      [s3_api]
      s3_region = "garage"
      api_bind_addr = "[::]:#{api_port}"
      root_domain = ".s3.garage.localhost"
    TOML

    spawn bin/"garage", "--config", testpath/"garage.toml", "server"
    sleep 5
    assert_match "==== HEALTHY NODES ====", shell_output("#{bin}/garage -c #{testpath}/garage.toml status")
  end
end
