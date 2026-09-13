class Tokei < Formula
  desc "Program that allows you to count code, quickly"
  homepage "https://github.com/XAMPPRocky/tokei"
  url "https://github.com/XAMPPRocky/tokei/archive/refs/tags/v15.0.0.tar.gz"
  sha256 "966da7b9a81ac6cb777b9f159f4c02e5b83a8b8bd30ebf5991007839926b600c"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/XAMPPRocky/tokei.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "a269b551ea4f5830a26c72086c28f3e2bc5db3c8291237f76e6c6d204be94db1"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(features: "all")
  end

  test do
    (testpath/"lib.rs").write <<~RUST
      #[cfg(test)]
      mod tests {
          #[test]
          fn test() {
              println!("It works!");
          }
      }
    RUST
    system bin/"tokei", "lib.rs"
  end
end
