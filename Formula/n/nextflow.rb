class Nextflow < Formula
  desc "Reproducible scientific workflows"
  homepage "https://nextflow.io"
  url "https://github.com/nextflow-io/nextflow/archive/refs/tags/v26.04.6.tar.gz"
  sha256 "485c4413948ddffce2bff02d8df63f6d5bbd88f7fd9c1a63d3a65a3cc8301b19"
  license "Apache-2.0"
  revision 1

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "3817748acf477a90b33602a10b6bdd3aa3c89728de958742b0871c8ed6c7695b"
  end

  depends_on "gradle" => :build
  # TODO: Switch back to `openjdk` once Nextflow supports JDK 27: 26.04.6 documents
  # "Java 17 (or later, up to 26)" and fails with "Unsupported class file major version 71".
  # https://www.nextflow.io/docs/latest/install.html#requirements
  depends_on "openjdk@25"

  def install
    ENV["BUILD_PACK"] = "1"

    system "gradle", "pack", "--no-daemon", "-x", "test"
    libexec.install "build/releases/nextflow-#{version}-dist" => "nextflow"

    (bin/"nextflow").write_env_script libexec/"nextflow", Language::Java.overridable_java_home_env("25")
  end

  test do
    (testpath/"hello.nf").write <<~NF
      process hello {
        publishDir "results", mode: "copy"

        output:
        path "hello.txt"

        script:
        """
        echo 'Hello!' > hello.txt
        """
      }
      workflow {
        hello()
      }
    NF

    system bin/"nextflow", "run", "hello.nf"

    assert_path_exists testpath/"results/hello.txt"
    assert_match "Hello!", (testpath/"results/hello.txt").read
  end
end
