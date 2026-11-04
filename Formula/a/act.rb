class Act < Formula
  desc "Run your GitHub Actions locally"
  homepage "https://nektosact.com"
  url "https://github.com/nektos/act/archive/refs/tags/v0.2.97.tar.gz"
  sha256 "807e43becd597f65c76c7d5dd6dbe5ff94285629214f6005ad18ce618b70e49c"
  license "MIT"
  head "https://github.com/nektos/act.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "074847e11a2799f254bf468f4fd443f6be42379012c01c4eb06a5a2410ebbf25"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "make", "build", "VERSION=#{version}"
    bin.install "dist/local/act"

    generate_completions_from_executable(bin/"act", shell_parameter_format: :cobra)
  end

  test do
    (testpath/".actrc").write <<~EOS
      -P ubuntu-latest=node:12.6-buster-slim
      -P ubuntu-12.04=node:12.6-buster-slim
      -P ubuntu-18.04=node:12.6-buster-slim
      -P ubuntu-16.04=node:12.6-stretch-slim
    EOS

    system "git", "clone", "https://github.com/stefanzweifel/laravel-github-actions-demo.git"

    cd "laravel-github-actions-demo" do
      system "git", "checkout", "v2.0"

      pull_request_jobs = shell_output("#{bin}/act pull_request --list")
      assert_match "php-cs-fixer", pull_request_jobs

      push_jobs = shell_output("#{bin}/act push --list")
      assert_match "phpinsights", push_jobs
      assert_match "phpunit", push_jobs
    end
  end
end
