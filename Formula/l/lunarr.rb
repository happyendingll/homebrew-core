class Lunarr < Formula
  desc "Self-hosted media streaming server and Plex alternative for movies and TV"
  homepage "https://github.com/lunarr-app/lunarr-go"
  url "https://github.com/lunarr-app/lunarr-go/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "e1d0317e8217d8a880e7b9eb340172dd6239854ca224bd845862e777ce6628c7"
  license "Apache-2.0"
  head "https://github.com/lunarr-app/lunarr-go.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "1b194e96399ea66095aa48ba8e69062371d09228e889fa9a9fc4ba7aadca39c5"
  end

  depends_on "ffmpeg"
  depends_on "node"

  # `better-auth` needs its exact `@better-auth/core`; npm otherwise resolves a newer one with mismatched peers
  resource "better-auth-core" do
    url "https://registry.npmjs.org/@better-auth/core/-/core-1.7.11.tgz"
    sha256 "ec150a0c7fee44737af5e5bf72dfcf1e80e2c863a8ec06445c7f8e4dd2c167b6"

    livecheck do
      url "https://raw.githubusercontent.com/lunarr-app/lunarr-go/refs/tags/v#{LATEST_VERSION}/package.json"
      regex(/(\d+(?:\.\d+)+)/)
      strategy :json do |json, regex|
        json.dig("dependencies", "better-auth")&.[](regex, 1)
      end
    end
  end

  def install
    system "npm", "install", *std_npm_args(prefix: false), *resources.map(&:cached_download)
    system "npm", "run", "build"
    system "npm", "prune", "--omit=dev"

    # strip the foreign slice of the universal binary to satisfy `brew audit`
    deuniversalize_machos "node_modules/fsevents/fsevents.node" if OS.mac?

    # keep only the prebuilt native libraries matching this platform;
    # @libsql suffixes the libc (`darwin-arm64`, `linux-arm64-gnu`) while
    # @seydx/node-av prefixes the package name (`node-av-darwin-arm64`)
    arch = Hardware::CPU.arm? ? "arm64" : "x64"
    os_arch = OS.mac? ? "darwin-#{arch}" : "linux-#{arch}"
    Dir["node_modules/@{libsql,seydx}/*"].each do |dir|
      base = File.basename(dir)
      rm_r(dir) unless base.end_with?(os_arch, "#{os_arch}-gnu")
    end

    libexec.install Dir["*"]
    (bin/"lunarr").write_env_script formula_opt_bin("node")/"node", libexec/"scripts/start.mjs",
                                    NODE_ENV:    "production",
                                    FFMPEG_PATH: formula_opt_bin("ffmpeg")/"ffmpeg"
  end

  service do
    run [opt_bin/"lunarr"]
    keep_alive true
    environment_variables LUNARR_DATA_DIR: var/"lunarr"
    log_path var/"log/lunarr.log"
    error_log_path var/"log/lunarr.log"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/lunarr --version").strip

    port = free_port
    ENV["LUNARR_DATA_DIR"] = (testpath/"data").to_s
    ENV["PORT"] = port.to_s
    pid = spawn bin/"lunarr"
    begin
      output = shell_output("curl --silent --retry 10 --retry-connrefused --retry-delay 3 " \
                            "http://127.0.0.1:#{port}/api/health")
      assert_match "\"ok\":true", output
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
