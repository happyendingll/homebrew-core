class Cake < Formula
  desc "Cross platform build automation system with a C# DSL"
  homepage "https://cakebuild.net/"
  url "https://github.com/cake-build/cake/archive/refs/tags/v6.3.0.tar.gz"
  sha256 "6db077c1a78323dce1b53a799e5c53ed4d864dd4f6c6d206d46e5d71733e3dcf"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "fd9327ef310c8a7ae046ffb55e3ce126baa43548bee23bac212a9016c9e595fa"
  end

  depends_on "dotnet"

  conflicts_with "coffeescript", because: "both install `cake` binaries"

  deny_network_access!

  def dotnet = deps.find { |d| d.name.match?(/^dotnet(@\d+)?$/) }.to_formula

  def fetch
    ENV["XDG_RUNTIME_DIR"] = buildpath
    system "dotnet", "restore", "src/Cake", "--use-current-runtime",
           "-p:TargetFrameworks=net#{dotnet.version.major_minor}"
  end

  def install
    ENV["XDG_RUNTIME_DIR"] = buildpath
    # Ignore dotnet version specification and use homebrew one
    rm "global.json"

    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{libexec}
      --no-self-contained
      --use-current-runtime
      -p:AppHostRelativeDotNet=#{dotnet.opt_libexec.relative_path_from(libexec)}
      -p:TargetFrameworks=net#{dotnet.version.major_minor}
      -p:Version=#{version}
      -p:WarningsNotAsErrors=NU1902%3BNU1903
    ]

    system "dotnet", "publish", "src/Cake", *args
    bin.install_symlink libexec/"Cake" => "cake"
  end

  test do
    (testpath/"build.cake").write <<~EOS
      var target = Argument ("target", "info");

      Task("info").Does(() =>
      {
        Information ("Hello Homebrew");
      });

      RunTarget ("info");
    EOS
    assert_match "Hello Homebrew", shell_output("#{bin}/cake build.cake")
  end
end
