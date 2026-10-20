class SpicetifyCli < Formula
  desc "Command-line tool to customize Spotify client"
  homepage "https://spicetify.app/"
  url "https://github.com/spicetify/cli/archive/refs/tags/v2.46.0/v2.46.0.tar.gz"
  sha256 "580b4aff8b26880c6312cc5f3039a1cc99ee500d3a261e2746f9f7c685a50c24"
  license "LGPL-2.1-only"
  head "https://github.com/spicetify/cli.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c9251285046f3cad72123392f3b3e90529a9d1d8f8baf213fc5cc03a9b7546fb"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c9251285046f3cad72123392f3b3e90529a9d1d8f8baf213fc5cc03a9b7546fb"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c9251285046f3cad72123392f3b3e90529a9d1d8f8baf213fc5cc03a9b7546fb"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "a2bdfe11a3b0924a1f949d5d8a90fb63e22c7b4bafaa4591c74f8745fa90f152"
    sha256 cellar: :any,                 x86_64_linux:      "75ca49ab1fd05236558432c7e016cacd3cc6c2e19c3359bd485fbccdb5dc3d0b"
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
