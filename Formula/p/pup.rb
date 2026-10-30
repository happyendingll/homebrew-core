class Pup < Formula
  desc "CLI companion with 200+ commands across 33+ Datadog products"
  homepage "https://www.datadoghq.com"
  url "https://github.com/DataDog/pup/releases/download/v2.3.8/pup_2.3.8_source.tar.gz"
  sha256 "dda2cd18c35c82e028338ae67e64be23bcdedfc6cdfea75c0299378673154398"
  license "Apache-2.0"
  head "https://github.com/DataDog/pup.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "02fb6bd1e8647c202f8e35f2bd7f4e797c1038578a907ca0cb46dabe1d5c7dc7"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "dd206348a04e06ffb50c3184ba270fc0663c0966da9e55f98f25a13fcd776970"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "596bbd2ab61d9f212efb9bcc61caf86d9bc601d64d35d07df588b6c392413dd8"
    sha256 cellar: :any,                 arm64_linux:       "7e249691f99610b3508c4ed482d7a3dabd6a40c9829f0f00b1e45262c4be88f4"
    sha256 cellar: :any,                 x86_64_linux:      "3a11354d97ea259d15b92b1b45e1fcbf24f7bd2604823ebf9e1e095552ee833d"
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
