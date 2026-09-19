class AskCli < Formula
  desc "CLI tool for Alexa Skill Kit"
  homepage "https://developer.amazon.com/en-US/docs/alexa/smapi/ask-cli-intro.html"
  url "https://registry.npmjs.org/ask-cli/-/ask-cli-2.30.7.tgz"
  sha256 "437b55f774064e053b0185956afc69ecb38a8b53c996a6e1e49960918b54f909"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "fbd9a39320014bcce65c042846dd0d428c96f34d351ce6b6c76646c2602cbe23"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.write_exec_script libexec/"bin/ask"

    node_modules = libexec/"lib/node_modules/ask-cli/node_modules"
    deuniversalize_machos node_modules/"fsevents/fsevents.node" if OS.mac?
  end

  test do
    output = shell_output("#{bin}/ask deploy 2>&1", 1)
    assert_match "File #{testpath}/.ask/cli_config not exists.", output
  end
end
