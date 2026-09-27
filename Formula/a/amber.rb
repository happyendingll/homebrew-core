class Amber < Formula
  desc "Crystal web framework. Bare metal performance, productivity and happiness"
  homepage "https://amberframework.org/"
  url "https://github.com/amberframework/amber/archive/refs/tags/v1.5.0.tar.gz"
  sha256 "12c7b576a5f2e0dba53962ca23d18435526a2b685924783d57cb0d507bd93a03"
  license "MIT"
  revision 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "972da5c1d8bb9afa3a3b7e9e20fffbd9a60e2e066057de6ab1306c8589ff8c39"
  end

  depends_on "bdw-gc"
  depends_on "crystal"
  depends_on "libyaml"
  depends_on "openssl@4"
  depends_on "pcre2"
  depends_on "sqlite"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "shards", "install", "--without-development"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    output = shell_output("#{bin}/amber new test_app")
    %w[
      config/environments
      amber.yml
      shard.yml
      public
      src/controllers
      src/views
      src/test_app.cr
    ].each do |path|
      assert_match path, output
    end

    ENV.prepend_path "PKG_CONFIG_PATH", formula_opt_lib("openssl@4")/"pkgconfig"
    cd "test_app" do
      shards = formula_opt_bin("crystal")/"shards"
      assert_match "Building", shell_output("#{shards} --without-development build test_app -Dwithout_mt")
    end
    assert_path_exists testpath/"test_app/bin/test_app"
  end
end
