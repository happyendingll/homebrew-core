class Dockerfmt < Formula
  desc "Dockerfile format and parser. a modern dockfmt"
  homepage "https://github.com/reteps/dockerfmt"
  url "https://github.com/reteps/dockerfmt/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "3bbed8d06a049bac352cbb06b7a369439578896f63a6995d1ac6b52c7b7fed52"
  license "MIT"
  head "https://github.com/reteps/dockerfmt.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "37716ccc3bd76b960b6405876716ec203f5b86bdaa7536135383a75ac3ed32dd"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X github.com/reteps/dockerfmt/cmd.Version=#{version}")
    generate_completions_from_executable(bin/"dockerfmt", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dockerfmt version")

    (testpath/"Dockerfile").write <<~DOCKERFILE
      from alpine:latest
      run   echo hi
    DOCKERFILE

    shell_output("#{bin}/dockerfmt --check Dockerfile", 1)
    system bin/"dockerfmt", "--write", "Dockerfile"
    assert_equal "FROM alpine:latest\nRUN echo hi\n", (testpath/"Dockerfile").read
    system bin/"dockerfmt", "--check", "Dockerfile"
  end
end
