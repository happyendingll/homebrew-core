class Pulumi < Formula
  desc "Cloud native development platform"
  homepage "https://www.pulumi.com/"
  url "https://github.com/pulumi/pulumi.git",
      tag:      "v3.269.0",
      revision: "194c65d84267b9d3f80831104e4d6feb89ff2daf"
  license "Apache-2.0"
  head "https://github.com/pulumi/pulumi.git", branch: "master"

  no_autobump! because: :bumped_by_upstream

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "361672984badbe073cb77ebb7ae9c04c1721fcd6478a35e7d048009555c3f718"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "71042f85e3392214b34a59fdb88e73f325a893f07bdea6f41094e889ed0d2721"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "31330217ec24c94673b67db322c1d693ca4c04c2bf32a975f1b3fb7223a3f446"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "2c112168ec2907d57caf6349414596b8ecb02d1d6c44e127c8c96631124aea5a"
    sha256 cellar: :any,                 x86_64_linux:      "c0ec3e48789716e4dec6bd532b8a542b99ca12041a154bf83ca838bf1906da5b"
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
