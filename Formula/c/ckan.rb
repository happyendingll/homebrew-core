class Ckan < Formula
  desc "Comprehensive Kerbal Archive Network"
  homepage "https://github.com/KSP-CKAN/CKAN/"
  url "https://github.com/KSP-CKAN/CKAN/archive/refs/tags/v1.36.4.tar.gz"
  sha256 "5b7d4257ccd760b809cd75a6b2b7bfb2fcf42c8bd492d6c1b61b04e7649b2aaf"
  license "MIT"
  revision 1

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "6bd6c7a79f90141cd20e9a642a4408da90af9b22fb536de70049c6fbd39adf34"
  end

  depends_on "dotnet@10"

  def install
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"
    # .NET's user-scoped named mutexes need a writable runtime directory on Linux.
    ENV["XDG_RUNTIME_DIR"] = buildpath

    dotnet = deps.find { |d| d.name.match? Version.formula_optionally_versioned_regex(:dotnet) }.to_formula
    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --no-self-contained
      --output #{libexec}
      --use-current-runtime
      -p:AppHostRelativeDotNet=#{dotnet.opt_libexec.relative_path_from(libexec)}
    ]

    system "dotnet", "publish", "Cmdline/CKAN-cmdline.csproj", *args
    bin.install_symlink libexec/"CKAN-CmdLine" => "ckan"
  end

  def caveats
    on_macos do
      <<~EOS
        If upgrading from a prior Mono-based install, you may want to migrate your
        appdata in "$HOME/.local/share/CKAN" to "$HOME/Library/Application Support/CKAN"
      EOS
    end
  end

  test do
    # On macOS .NET uses NSApplicationSupportDirectory which does not support $HOME.
    # Thus CKAN is expected to fail within sandboxed test when run for first time.
    if OS.mac?
      assert_match "Library/Application Support/CKAN' is denied.", pipe_output("#{bin}/ckan version 2>&1")
      return
    end

    assert_match version.to_s, shell_output("#{bin}/ckan version")

    output = shell_output("#{bin}/ckan update", 1)
    assert_match "I don't know where a game instance is installed", output
  end
end
