class Tunnelite < Formula
  desc "Secure tunneling to local applications"
  homepage "https://tunnelite.com"
  url "https://github.com/cristipufu/tunnelite/archive/refs/tags/v1.2.1.tar.gz"
  sha256 "3516585b6dc9d485bf2ffc7d11da3d75ed77c374fa37dc59889cc6151dafb834"
  license "MIT"
  head "https://github.com/cristipufu/tunnelite.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "0617414560df2c11d5c9b30c45920ea0a00838c7bf9150f929c0391ec0f342f8"
  end

  depends_on "dotnet"

  def install
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"
    ENV["DOTNET_SYSTEM_GLOBALIZATION_INVARIANT"] = "1"

    dotnet = Formula["dotnet"]
    # Force a single MSBuild node: worker-node sockets are denied by the macOS sandbox (Homebrew/brew#23920)
    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{libexec}
      --no-self-contained
      --use-current-runtime
      -p:PublishSingleFile=true
      -p:Version=#{version}
    ]
    system "dotnet", "publish", "src/Tunnelite.Client/Tunnelite.Client.csproj", *args

    env = { DOTNET_ROOT: "${DOTNET_ROOT:-#{dotnet.opt_libexec}}" }
    (bin/"tunnelite").write_env_script libexec/"Tunnelite.Client", env
  end

  test do
    # The sandbox denies FSEvents, so .NET's config file watcher would hang
    ENV["DOTNET_USE_POLLING_FILE_WATCHER"] = "1" if OS.mac?

    assert_match version.to_s, shell_output("#{bin}/tunnelite --version")
    assert_match "Unsupported protocol", shell_output("#{bin}/tunnelite ftp://localhost:1")
  end
end
