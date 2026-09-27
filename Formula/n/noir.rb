class Noir < Formula
  desc "Attack surface detector that identifies endpoints by static analysis"
  homepage "https://owasp.org/www-project-noir/"
  url "https://github.com/owasp-noir/noir/archive/refs/tags/v1.4.0.tar.gz"
  sha256 "65a496b1240dd93d8c2b0c4fdb4c5c74d715f59934b4d6ea09451ca796a9c41e"
  license "MIT"
  head "https://github.com/owasp-noir/noir.git", branch: "main"

  no_autobump! because: :bumped_by_upstream

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "fab90d78dd14f4b910255e7167f845900387d782fad728c519e7a7d0cd6c26c7"
    sha256 cellar: :any, arm64_tahoe:       "c60fb23d97b6a09e07dd3e375fbaeaf9592db108d8e090671d8b7c706fceed61"
    sha256 cellar: :any, arm64_sequoia:     "eac846748aa82f9da57c5cc5bac6eb0cc95227f562ac975d81ff58a5b9233aec"
    sha256 cellar: :any, arm64_linux:       "1caf94c53efeeea51beb3a411c74b0460621cba2fdff73169f0cabec97d3c839"
    sha256 cellar: :any, x86_64_linux:      "6a4e1aaae4ee25db5d468af3dbe856d493bd9a5818f9a65884625c6dc30c7ae2"
  end

  depends_on "crystal" => :build
  depends_on "pkgconf" => :build
  depends_on "bdw-gc"
  depends_on "libyaml"
  depends_on "openssl@3"
  depends_on "pcre2"

  uses_from_macos "libxml2"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def fetch
    system "shards", "install", "--production", "--skip-postinstall"
  end

  def install
    system "shards", "build", *std_shards_args
    bin.install "bin/noir"

    generate_completions_from_executable(bin/"noir", "--generate-completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/noir --version")

    (testpath/"api.py").write <<~PYTHON
      from fastapi import FastAPI

      app = FastAPI()

      @app.get("/hello")
      def hello():
          return {"Hello": "World"}
    PYTHON

    output = shell_output("#{bin}/noir scan --no-color . 2>&1")
    assert_match "Generating Report.", output
    assert_match "GET /hello", output
  end
end
