class Micronaut < Formula
  desc "Modern JVM-based framework for building modular microservices"
  homepage "https://micronaut.io/"
  url "https://github.com/micronaut-projects/micronaut-starter/archive/refs/tags/v5.1.4.tar.gz"
  sha256 "c4b63d883f75c7ad23894450690d1a3e1b83778aa2d9311d257cdc1bea6c7cd9"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "471dea5e51fdc731b3efc115a2c083e57df9113047ce3cc78c6f7498ac69c9d6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8007e024835ed396a44c372f5013d280d7c98d42bf10e714a6a89f1b6f8311ce"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "5683ec4885cc2658482bc17a22643dc25f2c7ffb7f94cc0c99ce0a0ee44bdd93"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "be31e4022cc423da4761a5bbca254b06062ed6065afc10bccd685dfc15e7f536"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "28173ebf842ca3bc79b67f9566068ca5bca916e1a798bc7c937f18abe10404f2"
  end

  depends_on "gradle" => :build
  depends_on "openjdk@25"

  def install
    ENV["JAVA_HOME"] = Language::Java.java_home("25")
    system "gradle", "micronaut-cli:assemble", "--exclude-task", "test", "--no-daemon"

    libexec.install "starter-cli/build/exploded/lib"
    (libexec/"bin").install "starter-cli/build/exploded/bin/mn"

    bash_completion.install "starter-cli/build/exploded/bin/mn_completion" => "mn"
    (bin/"mn").write_env_script libexec/"bin/mn", Language::Java.overridable_java_home_env("25")
  end

  test do
    system bin/"mn", "create-app", "hello-world"
    assert_predicate testpath/"hello-world", :directory?
  end
end
