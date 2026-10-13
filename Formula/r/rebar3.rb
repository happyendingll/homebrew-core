class Rebar3 < Formula
  desc "Erlang build tool"
  homepage "https://rebar3.org"
  url "https://github.com/erlang/rebar3/archive/refs/tags/3.27.2.tar.gz"
  sha256 "f4256c8e50c1df4e2dd3a54bb0d3576d261fd12e25b04a5d82e37fa3669ec3c0"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8531240aedd9f75007567a6f28cce599989cf2a4b18869527662dc088507bb5c"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "15add3d5e6092c811cb3fddcbf6989eb2557942e96e06199bdabb77fe6bf8943"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "9bb99e852544b29ea76670cbe55ef75fd984da743cbfa115c96adddd5df75140"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "c540cfce6246b25969271b23653152389032e519c05870bf66684cd40cd29510"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "d961587229f0c42b97401a80facbaf43cd36df5704c60c04df19a2a36a8a46d7"
  end

  depends_on "erlang@27" => [:build, :test]
  depends_on "erlang" => :test

  def install
    erlang_build_dep = deps.find { |dep| dep.build? && dep.name.match?(/^erlang@\d+$/) }&.to_formula
    odie "Could not find build-time erlang!" if erlang_build_dep.blank?

    # To guarantee compatibility with various erlang versions, build with an older erlang.
    # We want to use `erlang@#{x-2}` where x is the major version of the `erlang` formula.
    build_erlang_version = erlang_build_dep.version.major.to_i
    wanted_erlang_version = Formula["erlang"].version.major.to_i - 2
    if wanted_erlang_version != build_erlang_version
      odie "This formula should be built with `erlang@#{wanted_erlang_version}`"
    end

    # Ensure we're building with versioned `erlang`
    ENV.remove "PATH", "#{formula_opt_bin("erlang")}:"
    system "./bootstrap"
    bin.install "rebar3"

    bash_completion.install "apps/rebar/priv/shell-completion/bash/rebar3"
    zsh_completion.install "apps/rebar/priv/shell-completion/zsh/_rebar3"
    fish_completion.install "apps/rebar/priv/shell-completion/fish/rebar3.fish"
  end

  test do
    deps.each do |dep|
      next unless dep.name.match?(/^erlang(@\d+)?$/)

      erlang = dep.to_formula
      erlang_bin = erlang.opt_bin
      erlang_version = erlang.version.major
      with_env(PATH: "#{erlang_bin}:#{ENV["PATH"]}") do
        assert_match "OTP #{erlang_version}", shell_output("#{bin}/rebar3 --version")
      end
    end
  end
end
