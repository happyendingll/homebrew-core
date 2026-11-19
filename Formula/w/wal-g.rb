class WalG < Formula
  desc "Archival restoration tool for databases"
  homepage "https://github.com/wal-g/wal-g"
  url "https://github.com/wal-g/wal-g/archive/refs/tags/v3.0.10.tar.gz"
  sha256 "e7ad190500da1eb7cc7fdbe7e86543ce5b884992e99491042c5b2592caacf5fe"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "ed9b6f7cab4099465a677be9a86ea51735dece7cf8ee3d1fb7d4e80f61eaea1b"
  end

  depends_on "go" => :build
  depends_on "pkgconf" => :build
  depends_on "brotli"
  depends_on "libsodium"
  depends_on "lzo"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["GOEXPERIMENT"] = "jsonv2"
    ENV["CGO_ENABLED"] = "1"

    %w[etcd fdb gp mongo mysql pg redis sqlserver].each do |db|
      ldflags = %W[
        -X github.com/wal-g/wal-g/cmd/#{db}.buildDate=#{time.iso8601}
        -X github.com/wal-g/wal-g/cmd/#{db}.gitRevision=#{tap.user}
        -X github.com/wal-g/wal-g/cmd/#{db}.walgVersion=#{version}
      ]
      output = bin/"wal-g-#{db}"
      tags = %w[brotli libsodium lzo]
      system "go", "build", *std_go_args(ldflags:, output:, tags:), "./main/#{db}"
    end
  end

  test do
    ENV["WALG_FILE_PREFIX"] = testpath

    %w[etcd fdb gp mongo mysql pg redis sqlserver].each do |db|
      assert_match version.to_s, shell_output("#{bin}/wal-g-#{db} --version")

      flags = case db
      when "gp"
        "--config #{testpath}"
      when "mongo"
        "--mongodb-uri mongodb://"
      end
      assert_match "No backups found", shell_output("#{bin}/wal-g-#{db} backup-list #{flags} 2>&1")
    end
  end
end
