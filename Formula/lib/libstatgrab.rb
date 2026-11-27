class Libstatgrab < Formula
  desc "Provides cross-platform access to statistics about the system"
  homepage "https://libstatgrab.org/"
  url "https://github.com/libstatgrab/libstatgrab/releases/download/LIBSTATGRAB_0_92_2/libstatgrab-0.92.2.tar.gz"
  sha256 "ff559fcd4da75a4023af986c02c52ad51d4b68ae83fc0c8c461026126a8ebefa"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.1-or-later"]

  livecheck do
    url :stable
    regex(/^LIBSTATGRAB[._-]v?(\d+(?:[._]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.map { |tag| tag[regex, 1]&.tr("_", ".") }
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "8cadad16eb12ad806b79fe8aee7de50ca75084cd54ed9e10b34072f558505072"
  end

  deny_network_access!

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/statgrab general.os_name").chomp
    assert_equal "general.os_name = #{OS.kernel_name}", output
  end
end
