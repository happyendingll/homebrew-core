class Pulumi < Formula
  desc "Cloud native development platform"
  homepage "https://www.pulumi.com/"
  url "https://github.com/pulumi/pulumi.git",
      tag:      "v3.261.0",
      revision: "de0633d6c611507e17ddc5b6371640463b128522"
  license "Apache-2.0"
  head "https://github.com/pulumi/pulumi.git", branch: "master"

  no_autobump! because: :bumped_by_upstream

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "5c03883961d0dd1e03a5e99546c93ef013e1435572495f0e4bd3a329faecd324"
  end

  depends_on "go" => :build

  def install
    cd "./sdk" do
      system "go", "mod", "download"
    end

    cd "./pkg" do
      system "go", "mod", "download"
    end

    system "make", "brew"

    bin.install Dir["#{ENV["GOPATH"]}/bin/pulumi*"]

    # Install shell completions
    generate_completions_from_executable(bin/"pulumi", "gen-completion")
  end

  test do
    ENV["PULUMI_ACCESS_TOKEN"] = "local://"
    ENV["PULUMI_HOME"] = testpath

    (testpath/"template/Pulumi.yaml").write <<~YAML
      name: ${PROJECT}
      description: ${DESCRIPTION}
      runtime: nodejs
      template:
        description: minimal test template
    YAML
    (testpath/"template/index.ts").write "console.log(\"hi\");\n"

    assert_match "Your new project is ready to go!",
                 shell_output("#{bin}/pulumi new #{testpath}/template --generate-only --force --yes")
    assert_path_exists testpath/"index.ts"
  end
end
