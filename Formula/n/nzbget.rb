class Nzbget < Formula
  desc "Binary newsgrabber for nzb files"
  homepage "https://nzbget.com"
  license "GPL-2.0-or-later"
  head "https://github.com/nzbgetcom/nzbget.git", branch: "develop"

  stable do
    url "https://github.com/nzbgetcom/nzbget/archive/refs/tags/v26.3.tar.gz"
    sha256 "3a6a2a7c8bf5e7156dacb563e76d65df4aa53390e24040115c4406771ec3a19b"

    # Backport const-correctness changes from
    # https://github.com/nzbgetcom/nzbget/commit/f81d3f4de58fbfae9e0657a7eb3041ff6ab5adfd
    patch :DATA
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "c3366f67ea813bfa90064812187c3ad6b88447282d79bf1e13550639035e5ba5"
  end

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "openssl@4"
  depends_on "sevenzip"

  uses_from_macos "libxml2"
  uses_from_macos "ncurses"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    inreplace "nzbget.conf" do |s|
      if OS.mac?
        # Set upstream's recommended values for file systems without
        # sparse-file support (e.g., HFS+); see Homebrew/homebrew-core#972
        s.gsub! "DirectWrite=yes", "DirectWrite=no"
        s.gsub! "ArticleCache=0", "ArticleCache=700"
      end

      # Update 7z cmd to match homebrew binary
      s.gsub! "SevenZipCmd=7z", "SevenZipCmd=7zz"
    end

    etc.install "nzbget.conf"
  end

  service do
    run [opt_bin/"nzbget", "-c", HOMEBREW_PREFIX/"etc/nzbget.conf", "-s", "-o", "OutputMode=Log",
         "-o", "ConfigTemplate=#{HOMEBREW_PREFIX}/share/nzbget/nzbget.conf",
         "-o", "WebDir=#{HOMEBREW_PREFIX}/share/nzbget/webui"]
    keep_alive true
    environment_variables PATH: "#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  end

  test do
    (testpath/"downloads/dst").mkpath
    # Start nzbget as a server in daemon-mode
    system bin/"nzbget", "-D", "-c", etc/"nzbget.conf"
    # Query server for version information
    system bin/"nzbget", "-V", "-c", etc/"nzbget.conf"
    # Shutdown server daemon
    system bin/"nzbget", "-Q", "-c", etc/"nzbget.conf"
  end
end

__END__
diff --git a/daemon/connect/TlsSocket.cpp b/daemon/connect/TlsSocket.cpp
index 686032984..241832ddd 100644
--- a/daemon/connect/TlsSocket.cpp
+++ b/daemon/connect/TlsSocket.cpp
@@ -258,11 +258,11 @@ bool TlsSocket::ValidateCert()
 		if (common_name_loc >= 0)
 		{
 			// Extract the CN field
-			X509_NAME_ENTRY* common_name_entry = X509_NAME_get_entry(X509_get_subject_name(cert.get()), common_name_loc);
+			const X509_NAME_ENTRY* common_name_entry = X509_NAME_get_entry(X509_get_subject_name(cert.get()), common_name_loc);
 			if (common_name_entry != nullptr)
 			{
 				// Convert the CN field to a C string
-				ASN1_STRING* common_name_asn1 = X509_NAME_ENTRY_get_data(common_name_entry);
+				const ASN1_STRING* common_name_asn1 = X509_NAME_ENTRY_get_data(common_name_entry);
 				if (common_name_asn1 != nullptr)
 				{
 					certHost = ASN1_STRING_get0_data(common_name_asn1);
