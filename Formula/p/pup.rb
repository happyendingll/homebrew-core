class Pup < Formula
  desc "CLI companion with 200+ commands across 33+ Datadog products"
  homepage "https://www.datadoghq.com"
  url "https://github.com/DataDog/pup/releases/download/v2.2.1/pup_2.2.1_source.tar.gz"
  sha256 "6be4b0e835c3bd0721f987c349e84dd60715756ff5fb1830ae2b8567443d5790"
  license "Apache-2.0"
  head "https://github.com/DataDog/pup.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "d4005c8a294864ec31c6e863d5d7a4823b03753e412bd6bf10201f548726d3ea"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f52e93e806b59ba533c41401a727e94081804bd61a7b1f1404ee4979d254958e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f048012af6021420b01059901186014b77c0c2380990ed558986b07393de530a"
    sha256 cellar: :any,                 arm64_linux:       "a4bdf57c553a92ce97d69c07e6f1ca8a15019092391d4509a3061fcba05b7f04"
    sha256 cellar: :any,                 x86_64_linux:      "1bc4d7cca0b0c10045aa99a096233367e755621474c69766f1b1a63079c0f9dd"
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
