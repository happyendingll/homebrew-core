class Repo < Formula
  include Language::Python::Shebang

  desc "Repository tool for Android development"
  homepage "https://source.android.com/source/developing.html"
  url "https://gerrit.googlesource.com/git-repo.git",
      tag:      "v2.74.1",
      revision: "83eb32ef8758d5f89bdc7237b7513e40cadd1409"
  license "Apache-2.0"
  version_scheme 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "e033c1bd3de733837ca9e427d7714f724c6e9b6e84739ad265afab6016a7f0ad"
  end

  uses_from_macos "python"

  deny_network_access!

  def install
    bin.install "repo"
    doc.install (buildpath/"docs").children
    bash_completion.install "completion.bash" => "repo" if OS.linux? # needs GNU sed
    zsh_completion.install "completion.zsh" => "_repo"
    man1.install Utils::Gzip.compress(*Dir["man/*.1"])

    rewrite_shebang detected_python_shebang(use_python_from_path: true), bin/"repo"
  end

  test do
    assert_match "usage:", shell_output("#{bin}/repo help 2>&1")
  end
end
