class Gitversion < Formula
  desc "Easy semantic versioning for projects using Git"
  homepage "https://gitversion.net/docs/"
  url "https://github.com/GitTools/GitVersion/archive/refs/tags/7.0.1.tar.gz"
  sha256 "a6b01ce3850e132760da786be07b8603eb1a1492ba0476dd243117cd5e472731"
  license "MIT"

  no_autobump! because: :bumped_by_upstream

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "6bbfed25fe0c70033d8c1667e8ce1ae9a7311cb8fa8b170fb433f6b805a73d5d"
  end

  depends_on "dotnet"
  depends_on "openssl@4"

  deny_network_access!

  def dotnet = dep("dotnet").to_formula

  def fetch
    ENV["XDG_RUNTIME_DIR"] = buildpath
    # GitVersion uses a global.json file to pin the latest SDK version, which may not be available
    File.rename("global.json", "global.json.ignored")

    system "dotnet", "restore", "src/GitVersion.App/GitVersion.App.csproj", "--use-current-runtime"
  end

  def install
    ENV["DOTNET_SYSTEM_GLOBALIZATION_INVARIANT"] = "1"
    ENV["XDG_RUNTIME_DIR"] = buildpath

    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{libexec}
      --no-restore
      --no-self-contained
      --use-current-runtime
      -p:PublishSingleFile=true
      -p:Version=#{version}
    ]

    system "dotnet", "publish", "src/GitVersion.App/GitVersion.App.csproj", *args
    env = { DOTNET_ROOT: "${DOTNET_ROOT:-#{dotnet.opt_libexec}}" }
    # Ensure OpenSSL is available for cryptography operations on Linux
    if OS.linux?
      openssl_lib = dep("openssl").opt_lib
      env["LD_LIBRARY_PATH"] = "#{openssl_lib}:${LD_LIBRARY_PATH}"
    end
    (bin/"gitversion").write_env_script libexec/"gitversion", env
  end

  test do
    # The sandbox denies FSEvents, so .NET's config file watcher would hang
    ENV["DOTNET_USE_POLLING_FILE_WATCHER"] = "1" if OS.mac?

    # Circumvent GitVersion's build server detection scheme:
    ENV["GITHUB_ACTIONS"] = nil
    # .NET named mutexes need `XDG_RUNTIME_DIR` (or `USER`) on Linux, which test containers may lack
    ENV["XDG_RUNTIME_DIR"] = testpath

    (testpath/"test.txt").write("test")
    system "git", "init"
    system "git", "config", "user.name", "Test"
    system "git", "config", "user.email", "test@example.com"
    system "git", "add", "test.txt"
    system "git", "commit", "-q", "--message='Test'"
    assert_match '"FullSemVer": "0.0.1-1"', shell_output("#{bin}/gitversion --output json")
  end
end
