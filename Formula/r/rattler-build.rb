class RattlerBuild < Formula
  desc "Universal conda package builder"
  homepage "https://rattler.build"
  url "https://github.com/prefix-dev/rattler-build/archive/refs/tags/v0.78.0.tar.gz"
  sha256 "41909f3b98fd380fd7452c48669718c45ca030d9f9cef53db87ff54410ba1093"
  license "BSD-3-Clause"
  head "https://github.com/prefix-dev/rattler-build.git", branch: "main"

  # Upstream creates releases that use a stable tag (e.g., `v1.2.3`) but are
  # labeled as "pre-release" on GitHub before the version is released, so it's
  # necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "242ec3b54b79a9f2726489cf7adc8fd145b2d8ea34e9a4c9c2db427d3f4d1fb6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a5c009e973f8a5e87ede5c8f2989449db9205e6fa27823a45fa0f6569be4c837"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "282fad64f2715e597f5b17a5de55e45c42b6a709fdd471cb2d518ef58aa28dc0"
    sha256 cellar: :any,                 arm64_linux:       "bb6d6811e858dabfe4005a974c8e9beb92dc5c28e1be17f1e58b26baf90398a8"
    sha256 cellar: :any,                 x86_64_linux:      "06b9b579fc58c473bb3bf70f31a87c5ad56f16dc9a5d0e8294c77a23f67af65a"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"
  depends_on "xz"

  uses_from_macos "bzip2"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"rattler-build", "completion", "--shell")
  end

  test do
    (testpath/"recipe/recipe.yaml").write <<~YAML
      package:
        name: test-package
        version: '0.1.0'

      build:
        noarch: generic
        string: buildstring
        script:
          - mkdir -p "$PREFIX/bin"
          - echo "echo Hello World!" >> "$PREFIX/bin/hello"
          - chmod +x "$PREFIX/bin/hello"

      requirements:
        run:
          - python

      tests:
        - script:
          - test -f "$PREFIX/bin/hello"
          - hello | grep "Hello World!"
    YAML
    system bin/"rattler-build", "build", "--recipe", "recipe/recipe.yaml"
    assert_path_exists testpath/"output/noarch/test-package-0.1.0-buildstring.conda"

    assert_match version.to_s, shell_output("#{bin}/rattler-build --version")
  end
end
