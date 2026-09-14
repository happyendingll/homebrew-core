class Micronaut < Formula
  desc "Modern JVM-based framework for building modular microservices"
  homepage "https://micronaut.io/"
  url "https://github.com/micronaut-projects/micronaut-starter/archive/refs/tags/v5.1.5.tar.gz"
  sha256 "d6fd459e43f41bad94188357fc21c84f20b7a2e92d290a203ae77c6f62507d8c"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "ff396ebeef9928355bb3616d099b1a9dbbb0fe050630d31c3d0df647c986b643"
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
