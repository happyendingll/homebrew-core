class Pythia < Formula
  desc "Monte Carlo event generator"
  homepage "https://pythia.org"
  url "https://pythia8.web.cern.ch/releases/pythia83/pythia8318.tgz"
  version "8.318"
  sha256 "85dce1e623f91499b2973e3f939bf760b0f745ad4f4eb1bd0fbce2074e2e8f5c"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://pythia.org/releases"
    regex(/href=.*?pythia(\d)(\d{3})\.t/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match.join(".") }
    end
  end

  no_autobump! because: :incompatible_version_format

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "804a2ae6e8d554be5ac62f78839f07423d1df3a421ea5602a67678cd1f61c34f"
  end

  uses_from_macos "rsync" => :build

  def install
    system "./configure", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.cc").write <<~CPP
      #include "Pythia8/Pythia.h"

      int main() {
        Pythia8::Pythia pythia;
        return pythia.settings.mode("Beams:idA") == 2212 ? 0 : 1;
      }
    CPP

    flags = shell_output("#{bin}/pythia8-config --cxxflags --libs").split
    system ENV.cxx, "test.cc", "-o", "test", *flags
    system "./test"
  end
end
