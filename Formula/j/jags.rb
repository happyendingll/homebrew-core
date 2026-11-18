class Jags < Formula
  desc "Just Another Gibbs Sampler for Bayesian MCMC simulation"
  homepage "https://mcmc-jags.sourceforge.io"
  url "https://downloads.sourceforge.net/project/mcmc-jags/JAGS/5.x/Source/JAGS-5.0.2.tar.gz"
  sha256 "80143e23fc6feca01d4cce440fd8f6aa865a03333ed36baf9e0ce30a8f9e3aea"
  license "GPL-2.0-only"

  livecheck do
    url :stable
    regex(%r{url=.*?/JAGS[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "cfe83920d2c7ba4b79a15d3359e45e821801fb9cd09744a1b6570a84a6734413"
  end

  depends_on "pkgconf" => :build
  depends_on "gcc"
  depends_on "openblas"

  deny_network_access!

  def install
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"model.bug").write <<~EOS
      data {
        obs <- 1
      }
      model {
        parameter ~ dunif(0,1)
        obs ~ dbern(parameter)
      }
    EOS
    (testpath/"script").write <<~EOS
      model in model.bug
      compile
      initialize
      monitor parameter
      update 100
      coda *
    EOS
    system bin/"jags", "script"
  end
end
