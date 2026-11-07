class GphotosUploaderCli < Formula
  desc "Command-line tool to mass upload media folders to Google Photos"
  homepage "https://gphotosuploader.github.io/gphotos-uploader-cli/"
  url "https://github.com/gphotosuploader/gphotos-uploader-cli/archive/refs/tags/v6.0.0.tar.gz"
  sha256 "99fdc60442f8ff39a01dc97544509749553279ea03caee230a055eb0fcdf0e7e"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "9dab129861d83b0ded698035104b0abb93a1d91c3d750d5c29f61af17d826c67"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X github.com/gphotosuploader/gphotos-uploader-cli/version.versionString=#{version}]
    system "go", "build", *std_go_args(ldflags:)
    generate_completions_from_executable(bin/"gphotos-uploader-cli", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gphotos-uploader-cli version 2>&1")

    system bin/"gphotos-uploader-cli", "init", "--config", testpath
    assert_path_exists testpath/"config.hjson"
  end
end
