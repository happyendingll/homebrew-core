class Act < Formula
  desc "Run your GitHub Actions locally"
  homepage "https://nektosact.com"
  url "https://github.com/nektos/act/archive/refs/tags/v0.2.90.tar.gz"
  sha256 "309936a6e5502e454cfd2582c8e4a26d460356095d444af1b1884da5acdf06bc"
  license "MIT"
  head "https://github.com/nektos/act.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "d4cc68ff2424016b82513f5bf8da87f2c9197e10d75c3f9a288cb926e57741f3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "e0cd1f16a3079835e327c80f3d9cf39364d54923912f1a42bff9cd8396e230d5"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "fe2b140237987579705951fe9fa2cbea2525e5bf3e36518c7bc5dc30fc21c072"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "6dee00dbf3c367bc49fb0d2cfdabfcadd2585508c76fb5e0cde9ee387a0e0ff8"
    sha256 cellar: :any,                 x86_64_linux:      "05acb39b8c79127d1b1e08085cd5d31b80be9ca75f985c72c2567c9d5749ce88"
  end

  depends_on "go" => :build

  deny_network_access! [:postinstall]

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
