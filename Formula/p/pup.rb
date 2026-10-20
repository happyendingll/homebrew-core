class Pup < Formula
  desc "CLI companion with 200+ commands across 33+ Datadog products"
  homepage "https://www.datadoghq.com"
  url "https://github.com/DataDog/pup/releases/download/v2.0.1/pup_2.0.1_source.tar.gz"
  sha256 "84cd688833dd58321ff7eeacde7b67af6dfb5b999c54fafd7d5411fc3b557d62"
  license "Apache-2.0"
  head "https://github.com/DataDog/pup.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "83fbbc8caab724c63709d7a9e62135a062274e0a222976a7b639ba84fbffa24a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f1b201ededa1b8a45d5b0dc71ed35050288445db26a64694996a7750b6567b96"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "2edf6d8dd681a4701949569ae26bc591044c7b41a492273aaa983713d0ad9423"
    sha256 cellar: :any,                 arm64_linux:       "0b5ea8633eec96187f4a60779494f314373910390b62b356fb57686f64b7e09f"
    sha256 cellar: :any,                 x86_64_linux:      "3e86896020d854ef2242611ff8462166413b3854568e6748a21f88cca3b6b049"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"pup", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pup --version")
    assert_match "Use pup CLI or generate code", shell_output("#{bin}/pup skills list")
  end
end
