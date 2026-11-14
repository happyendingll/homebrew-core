class Tunnelite < Formula
  desc "Secure tunneling to local applications"
  homepage "https://tunnelite.com"
  url "https://github.com/cristipufu/tunnelite/archive/refs/tags/v1.3.2.tar.gz"
  sha256 "384af1fbac09b5cda738127b55cd178deb5e43bd7dbb90e7f2e73f458212e726"
  license "MIT"
  revision 1
  head "https://github.com/cristipufu/tunnelite.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "36c92ccfec6cd94ea2f741cc2659a4f0734e155d0be823ebfcc063fc0205af9d"
  end

  depends_on "dotnet@10"

  def install
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"
    ENV["DOTNET_SYSTEM_GLOBALIZATION_INVARIANT"] = "1"
    # .NET's user-scoped named mutexes need a writable runtime directory on Linux.
    ENV["XDG_RUNTIME_DIR"] = buildpath

    dotnet = deps.find { |d| d.name.match? Version.formula_optionally_versioned_regex(:dotnet) }.to_formula
    # Force a single MSBuild node: worker-node sockets are denied by the macOS sandbox (Homebrew/brew#23920)
    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{bin}
      --no-self-contained
      --use-current-runtime
      -p:AppHostRelativeDotNet=#{dotnet.opt_libexec.relative_path_from(bin)}
      -p:DebugType=None
      -p:PublishSingleFile=true
      -p:Version=#{version}
    ]
    system "dotnet", "publish", "src/Tunnelite.Client/Tunnelite.Client.csproj", *args
    # Rename to match https://github.com/cristipufu/tunnelite/blob/master/.github/workflows/release.yml
    mv bin/"Tunnelite.Client", bin/"tunnelite"
  end

  test do
    # The sandbox denies FSEvents, so .NET's config file watcher would hang
    ENV["DOTNET_USE_POLLING_FILE_WATCHER"] = "1" if OS.mac?

    assert_match version.to_s, shell_output("#{bin}/tunnelite --version")
    shell_output("#{bin}/tunnelite ftp://localhost:1 2>&1", 1)
  end
end
