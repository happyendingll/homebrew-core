class Hister < Formula
  desc "Self-hosted search engine for your browsing history"
  homepage "https://hister.org/"
  url "https://github.com/asciimoo/hister/archive/refs/tags/v0.19.0.tar.gz"
  sha256 "59cbe6d03a7e7783e4922ea03fbbbe812701c50eb5f49f6a3c42d9480ebdd2ba"
  license "AGPL-3.0-or-later"
  head "https://github.com/asciimoo/hister.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "0a7e982ebcf5a4fdc6040566c900c0f276fb0927945ebefbec52a660ebad64c0"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
    system "npm", "ci", "--workspaces", "--include=optional"
  end

  def install
    system "npm", "--offline", "run", "build", "--workspace=@hister/app"
    (buildpath/"server/static/app").install Dir["webui/app/build/*"]

    ENV["CGO_ENABLED"] = "1" if OS.linux?
    ENV["GOPROXY"] = "off"
    system "go", "build", *std_go_args
    generate_completions_from_executable(bin/"hister", "completion")
  end

  service do
    run [opt_bin/"hister", "listen"]
    keep_alive true
    environment_variables HISTER_DATA_DIR: var/"hister"
    log_path var/"log/hister.log"
    error_log_path var/"log/hister.log"
    working_dir var/"hister"
  end

  test do
    require "yaml"

    ENV["HISTER_DATA_DIR"] = testpath/"data"
    assert_match version.to_s, shell_output("#{bin}/hister --version")

    config = testpath/"hister.yml"
    system bin/"hister", "create-config", config
    assert_match "app:", config.read

    documents = testpath/"documents"
    documents.mkpath
    (documents/"note.md").write "Homebrew test document"
    (documents/"ignored.txt").write "Excluded by the file type filter"

    config_data = YAML.safe_load(config.read)
    config_data["indexer"]["directories"] = [{ "path" => documents.to_s, "filetypes" => ["md"] }]
    config.atomic_write config_data.to_yaml

    assert_equal "note.md\n", shell_output("#{bin}/hister --config #{config} list-files --relative")
  end
end
