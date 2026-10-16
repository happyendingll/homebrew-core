class Vermin < Formula
  include Language::Python::Virtualenv

  desc "Concurrently detect the minimum Python versions needed to run code"
  homepage "https://github.com/netromdk/vermin"
  url "https://files.pythonhosted.org/packages/1b/29/4fa4bb0f381bbd257bc578e8cc5b535c60229dc370575f6c983ddf37ea16/vermin-1.9.0.tar.gz"
  sha256 "92dfd9c23109b548d77bf50ccf47df22e5383a3f585a055cf3255febbad57127"
  license "MIT"
  head "https://github.com/netromdk/vermin.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "d429c49c21f32716b179ff39691d31fee0afea072378ef48d9bd19b0168d7408"
  end

  depends_on "python@3.15"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_equal <<~EOS, shell_output("#{bin}/vermin --no-parse-comments #{bin}/vermin")
      Minimum required versions: ~2, ~3
      Note: Not enough evidence to conclude it won't work with Python 2 or 3.
    EOS

    assert_match version.to_s, shell_output("#{bin}/vermin --version")
  end
end
