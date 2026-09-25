class Ytt < Formula
  desc "YAML templating tool that works on YAML structure instead of text"
  homepage "https://carvel.dev/ytt/"
  url "https://github.com/carvel-dev/ytt/archive/refs/tags/v0.55.3.tar.gz"
  sha256 "ff45d6b34342714223b75a98bf089c108c928b3d8247651c4aa70c152ee42719"
  license "Apache-2.0"
  head "https://github.com/carvel-dev/ytt.git", branch: "develop"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "8806061ed0fa191861235f6e6dd8964a65a6c3314e34fe251fb23522287a33bf"
  end

  depends_on "go" => :build

  deny_network_access!

  def install
    ldflags = "-X carvel.dev/ytt/pkg/version.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/ytt"

    generate_completions_from_executable(bin/"ytt", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ytt version")

    (testpath/"values.lib.yml").write <<~YAML
      #@ def func1():
      name: max
      cities:
      - SF
      - LA
      #@ end

      #@ def func2():
      name: joanna
      cities:
      - SF
      #@ end
    YAML

    (testpath/"template.yml").write <<~YAML
      #! YAML library files must be named *.lib.yml
      #@ load("values.lib.yml", "func1", "func2")

      func1_key: #@ func1()
      func2_key: #@ func2()
    YAML

    assert_match <<~YAML, shell_output("#{bin}/ytt -f values.lib.yml -f template.yml")
      func1_key:
        name: max
        cities:
        - SF
        - LA
    YAML
  end
end
