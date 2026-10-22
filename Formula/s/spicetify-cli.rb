class SpicetifyCli < Formula
  desc "Command-line tool to customize Spotify client"
  homepage "https://spicetify.app/"
  url "https://github.com/spicetify/cli/archive/refs/tags/v2.46.2/v2.46.2.tar.gz"
  sha256 "f4251e342851d2a9edf01c3cee6a66501ee9a29c58b4adf79a0ca548b1044da5"
  license "LGPL-2.1-only"
  head "https://github.com/spicetify/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "cf5e965a9561272fea459c8e935ebdb053bc2dd1f920a65a1425dd7e66f1fda4"
  end

  depends_on "go" => :build
  depends_on "node" => :build
  depends_on "pnpm" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
    system "pnpm", "with", "current", "install", "--frozen-lockfile"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}", output: libexec/"spicetify")

    system "pnpm", "--offline", "with", "current", "run", "build:wrapper"

    libexec.install [
      "css-map.json",
      "CustomApps",
      "Extensions",
      "globals.d.ts",
      "jsHelper",
      "Themes",
    ]
    bin.install_symlink libexec/"spicetify"
  end

  test do
    spotify_folder = testpath/"com.spotify.Client"
    pref_file = spotify_folder/"com.spotify.client.plist"
    mkdir_p spotify_folder
    touch pref_file

    path = testpath/".config/spicetify/config-xpui.ini"
    path.write <<~INI
      [Setting]
      spotify_path            = #{spotify_folder}
      current_theme           = SpicetifyDefault
      prefs_path              = #{pref_file}
    INI

    quiet_system bin/"spicetify", "config"
    assert_match version.to_s, shell_output("#{bin}/spicetify -v")

    output = shell_output("#{bin}/spicetify config current_theme")
    assert_match "SpicetifyDefault", output
  end
end
