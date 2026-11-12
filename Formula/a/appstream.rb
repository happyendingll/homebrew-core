class Appstream < Formula
  desc "Tools and libraries to work with AppStream metadata"
  homepage "https://www.freedesktop.org/wiki/Distributions/AppStream/"
  url "https://github.com/ximion/appstream/archive/refs/tags/v1.2.3.tar.gz"
  sha256 "12f01e127081c485a3e3056b6d30f54d003101689ff815adac6f1ef2b19af6ab"
  license "LGPL-2.1-or-later"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 sequoia: "b43c7dfc936e0ce643de44849407ca75796cc16afb5e967b4eeb0845881dc762"
  end

  depends_on "docbook-xsl" => :build
  depends_on "gobject-introspection" => :build
  depends_on "itstool" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "vala" => :build

  depends_on "glib"
  depends_on "libfyaml"
  depends_on "libxmlb"
  depends_on "zstd"

  uses_from_macos "libxslt" => :build # for xsltproc
  uses_from_macos "python" => :build
  uses_from_macos "curl"
  uses_from_macos "libxml2"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "gettext" => :build
    depends_on "gperf" => :build
    depends_on "systemd"
    depends_on "wayland"
  end

  deny_network_access!

  def install
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    args = %w[
      -Dstemming=false
      -Dvapi=true
      -Dgir=true
      -Ddocs=false
      -Dapidocs=false
      -Dinstall-docs=false
      -Dbash-completion=false
      -Ddisplay-detection=auto
    ]

    args << "-Dsystemd=false" if OS.mac?

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"appdata.xml").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <component type="desktop-application">
        <id>org.test.test-app</id>
        <name>Test App</name>
      </component>
    XML
    (testpath/"test.c").write <<~C
      #include "appstream.h"

      int main(int argc, char *argv[]) {
        GFile *appdata_file;
        char *appdata_uri;
        AsMetadata *metadata;
        GError *error = NULL;
        char *resource_path = "#{testpath}/appdata.xml";
        appdata_file = g_file_new_for_path (resource_path);
        metadata = as_metadata_new ();
        if (!as_metadata_parse_file (metadata, appdata_file, AS_FORMAT_KIND_UNKNOWN, &error)) {
          g_error ("Could not parse metadata file: %s", error->message);
          g_clear_error (&error);
        }
      }
    C
    flags = shell_output("pkg-config --cflags --libs appstream").strip.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"

    assert_match version.to_s, shell_output("#{bin}/appstreamcli --version")
  end
end
