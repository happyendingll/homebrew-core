class Resterm < Formula
  desc "Terminal client for .http/.rest files with HTTP, GraphQL, and gRPC support"
  homepage "https://github.com/unkn0wn-root/resterm"
  url "https://github.com/unkn0wn-root/resterm/archive/refs/tags/v1.17.1.tar.gz"
  sha256 "9f45c4f1189395d66babc69d597cc73551ea895adab05a6cc8a587a8066a27ca"
  license "Apache-2.0"
  head "https://github.com/unkn0wn-root/resterm.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "d3f9f45df7b439966262ddf5a3db91c04d1c0f78651a49e44546c4e9f80daeb7"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "d3f9f45df7b439966262ddf5a3db91c04d1c0f78651a49e44546c4e9f80daeb7"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "d3f9f45df7b439966262ddf5a3db91c04d1c0f78651a49e44546c4e9f80daeb7"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "fcbb4cbdeba90233f2ad73e5ec5c3207da925b5fb8ab87655341af8db67f8ea1"
    sha256 cellar: :any,                 x86_64_linux:      "7fcc5ab78fd69e63852dea1bf17e109c0d984e00d187f4fa643667af20b7ca67"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/resterm"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/resterm -version")

    (testpath/"openapi.yml").write <<~YAML
      openapi: 3.0.0
      info:
        title: Test API
        version: 1.0.0
        description: A simple test API
      servers:
        - url: https://api.example.com
          description: Production server
      paths:
        /ping:
          get:
            summary: Ping endpoint
            operationId: ping
            responses:
              "200":
                description: Successful response
                content:
                  application/json:
                    schema:
                      type: object
                      properties:
                        message:
                          type: string
                          example: "pong"
      components:
        schemas:
          PingResponse:
            type: object
            properties:
              message:
                type: string
    YAML

    system bin/"resterm", "--from-openapi", testpath/"openapi.yml",
                          "--http-out",     testpath/"out.http",
                          "--openapi-base-var", "apiBase",
                          "--openapi-server-index", "0"

    assert_match "GET {{apiBase}}/ping", (testpath/"out.http").read
  end
end
