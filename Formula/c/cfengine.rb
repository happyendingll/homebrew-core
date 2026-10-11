class Cfengine < Formula
  desc "Help manage and understand IT infrastructure"
  homepage "https://cfengine.com/"
  url "https://cfengine-package-repos.s3.amazonaws.com/tarballs/cfengine-community-3.28.0.tar.gz"
  sha256 "03722ab589c00b4e823ee22eb0afef5611b82e4f764fccc37ad3b18a3732c49e"
  license all_of: ["BSD-3-Clause", "GPL-2.0-or-later", "GPL-3.0-only", "LGPL-2.0-or-later"]
  revision 1

  livecheck do
    url "https://cfengine-package-repos.s3.amazonaws.com/release-data/community/releases.json"
    strategy :json do |json|
      json["releases"]&.map do |release|
        next if release["beta"] || release["debug"]

        release["version"]
      end
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "885bb1f66dbc1b8e4a4b93c2223f46aaa0cba90114e1c95853e94e272e297e90"
  end

  depends_on "librsync"
  depends_on "lmdb"
  depends_on "openssl@4"
  depends_on "pcre2"

  uses_from_macos "curl", since: :ventura # uses CURLOPT_PROTOCOLS_STR, available since curl 7.85.0
  uses_from_macos "libxml2"

  on_linux do
    depends_on "linux-pam"
  end

  resource "masterfiles" do
    url "https://cfengine-package-repos.s3.amazonaws.com/tarballs/cfengine-masterfiles-3.28.0.tar.gz"
    sha256 "e044ce5926491e649f96c943482bf56bc268389fcb5d2edc4bcc4e94ceff09aa"

    livecheck do
      formula :parent
    end
  end

  def install
    odie "masterfiles resource needs to be updated" if version != resource("masterfiles").version

    args = %W[
      --with-workdir=#{var}/cfengine
      --with-lmdb=#{formula_opt_prefix("lmdb")}
      --with-pcre2=#{formula_opt_prefix("pcre2")}
      --without-mysql
      --without-postgresql
    ]

    args << "--with-systemd-service=no" if OS.linux?

    system "./configure", *args, *std_configure_args
    system "make", "install"
    (pkgshare/"CoreBase").install resource("masterfiles")
  end

  post_install_steps do
    set_permissions %w[cfengine/inputs cfengine/outputs cfengine/ppkeys cfengine/plugins], "0700",
                    recursive: false, base: :var
    set_permissions "cfengine/state", "0750", recursive: false, base: :var
    set_permissions "cfengine/modules", "0755", recursive: false, base: :var
  end

  test do
    assert_equal "CFEngine Core #{version}", shell_output("#{bin}/cf-agent -V").chomp
  end
end
