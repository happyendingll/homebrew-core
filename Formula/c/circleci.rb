class Circleci < Formula
  desc "Official command-line tool for CircleCI"
  homepage "https://cli.circleci.com"
  # Updates should be pushed no more frequently than once per week.
  url "https://github.com/CircleCI-Public/circleci-cli.git",
      tag:      "v1.0.49774",
      revision: "143b722d53790a47c30ed5228f9f852538ce2281"
  license "MIT"
  head "https://github.com/CircleCI-Public/circleci-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "fd2ea898aec073479adc2341294c9d484408023750f86009931614c50fad2f92"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e72e209a1447209945c9975c02ce88f587acc1b746f51ce9f61d9a6828a73bf2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "fa66b4cad3f4b94815706db4bb076f930b5111ab4914f94f20faf8de33b5d61a"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "ff3e456f6681c6a15acb361f8985fe5860eb9f9e3f220efed7e1c4a29967e2ed"
    sha256 cellar: :any,                 x86_64_linux:  "1a5fc3ea6fdebc1de2ff0f2d1fc3940bfd8d8c3a4be4fd4e99e2219f058f928b"
  end

  depends_on "go" => :build

  def install
    ldflags = "-X main.version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/circleci"

    generate_completions_from_executable(bin/"circleci", "completion")
    system bin/"circleci", "man", "--output", man1/"circleci.1"
  end

  test do
    ENV["DO_NOT_TRACK"] = "1"
    # assert basic script execution
    assert_match(/^circleci #{version} \(\h{12}\)$/, shell_output("#{bin}/circleci version").strip)
    (testpath/".circleci.yml").write("{version: 2.1}")
    output = shell_output("#{bin}/circleci config pack #{testpath}/.circleci.yml")
    assert_match "version: 2.1", output
  end
end
