class Jags < Formula
  desc "Just Another Gibbs Sampler for Bayesian MCMC simulation"
  homepage "https://mcmc-jags.sourceforge.io"
  url "https://downloads.sourceforge.net/project/mcmc-jags/JAGS/5.x/Source/JAGS-5.0.1.tar.gz"
  sha256 "0888571b1812c8ce076ad6326c66f96a0ae7762497c346cd7eb32d35a62105d4"
  license "GPL-2.0-only"

  livecheck do
    url :stable
    regex(%r{url=.*?/JAGS[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "5de99162ba32d2530e9130dc24568a5a1a204ff5e11b1ee2148b8e497159d2d3"
  end

  depends_on "pkgconf" => :build
  depends_on "gcc"
  depends_on "openblas"

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
