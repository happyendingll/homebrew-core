class Pup < Formula
  desc "CLI companion with 200+ commands across 33+ Datadog products"
  homepage "https://www.datadoghq.com"
  url "https://github.com/DataDog/pup/releases/download/v2.3.1/pup_2.3.1_source.tar.gz"
  sha256 "5d9eae20969058853c90a7db65119c18e2fc8a606f2c7eadedb73a2d8753a97f"
  license "Apache-2.0"
  head "https://github.com/DataDog/pup.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "93edfe7a37ab67848430758bc3f4be97a4554276a016f138f970a659ede7e4cd"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "b7afb9773d141741355cfe815a055bb76f07a8a844bbb27ad47f4b535d41dab6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f616e6bc354c94ee9b5d37d727ca4d5a01d710cd94f5582ca14ae5ae2ed95337"
    sha256 cellar: :any,                 arm64_linux:       "6bd1c35b3ce76a130320d7fc8e299666ed638c1ded9b2a5820cc4cb0b5c18bbd"
    sha256 cellar: :any,                 x86_64_linux:      "fadb6e199cf2d2f45c73c99bd752f4b007ea6016b3eedce715958bebab1ee5d0"
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
