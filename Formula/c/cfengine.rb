class Cfengine < Formula
  desc "Help manage and understand IT infrastructure"
  homepage "https://cfengine.com/"
  url "https://cfengine-package-repos.s3.amazonaws.com/tarballs/cfengine-community-3.29.0.tar.gz"
  sha256 "83ce77165543884de90a1ee69ae8728fd4a7c6a41e6b470dc5df48b48107d6c7"
  license all_of: ["BSD-3-Clause", "GPL-2.0-or-later", "GPL-3.0-only", "LGPL-2.0-or-later"]

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
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 sequoia: "1948c52449705d8855ef6fa3e82a2c01e16839f901b3087eb0a3e6b6930eb2a1"
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
    url "https://cfengine-package-repos.s3.amazonaws.com/tarballs/cfengine-masterfiles-3.29.0.tar.gz"
    sha256 "db0a97ae7ee1f46430b5ad79127a7594849a222adc1934eeb3e5aa14843ff47e"

    livecheck do
      formula :parent
    end
  end

  deny_network_access!

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
