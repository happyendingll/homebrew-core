class Opam < Formula
  desc "OCaml package manager"
  homepage "https://opam.ocaml.org"
  url "https://github.com/ocaml/opam/releases/download/2.6.0/opam-full-2.6.0.tar.gz"
  sha256 "eba7360253fd791eb9edaabe4848ea0c59b35da5f5f5dbaaff5eb68bf618ca08"
  license "LGPL-2.1-only"
  head "https://github.com/ocaml/opam.git", branch: "master"

  # Upstream sometimes publishes tarballs with a version suffix (e.g. 2.2.0-2)
  # to an existing tag (e.g. 2.2.0), so we match versions from release assets.
  livecheck do
    url :stable
    regex(/^opam-full[._-]v?(\d+(?:[.-]\d+)+)\.t/i)
    strategy :github_latest do |json, regex|
      json["assets"]&.map do |asset|
        match = asset["name"]&.match(regex)
        next if match.blank?

        match[1]
      end
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "779b7e20b7c1e2116847e984710e47851f7b884e9dc7fc3a19b2b478c451ca6b"
  end

  depends_on "ocaml" => [:build, :test]
  depends_on "rsync" # macOS's openrsync won't work (see https://github.com/ocaml/opam/issues/6628)

  uses_from_macos "unzip"

  allow_network_access! :test

  def install
    ENV.deparallelize

    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}", "--with-vendored-deps", "--with-mccs"
    system "make"
    system "make", "install"

    bash_completion.install "src/state/shellscripts/complete.sh" => "opam"
    zsh_completion.install "src/state/shellscripts/complete.zsh" => "_opam"
  end

  def caveats
    <<~EOS
      OPAM uses ~/.opam by default for its package database, so you need to
      initialize it first by running:

      $ opam init
    EOS
  end

  test do
    system bin/"opam", "init", "--auto-setup", "--compiler=ocaml-system", "--disable-sandboxing"
    system bin/"opam", "list"
  end
end
