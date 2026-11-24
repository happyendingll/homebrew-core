class Janet < Formula
  desc "Dynamic language and bytecode vm"
  homepage "https://janet-lang.org"
  url "https://github.com/janet-lang/janet/archive/refs/tags/v1.43.1.tar.gz"
  sha256 "01e82762eac894af315db2e1e0cecdf3a935a27e2cde79ec1b8840a8a5ae0e85"
  license "MIT"
  head "https://github.com/janet-lang/janet.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "5007889f3bf02d3725a0ccfe3b0f2d8211f8e6034b5816f843fe42d58e278bca"
  end

  resource "jpm" do
    url "https://github.com/janet-lang/jpm/archive/refs/tags/v1.2.0.tar.gz"
    sha256 "4282b36b44a9b35367d128982f2cfaa67370e4e5a305b3999d86a64fadd308d2"
  end

  def syspath
    HOMEBREW_PREFIX/"lib/janet"
  end

  def install
    # Replace lines in the Makefile that attempt to create the `syspath`
    # directory (which is a directory outside the sandbox).
    inreplace "Makefile", /^.*?\bmkdir\b.*?\$\(JANET_PATH\).*?$/, "#"

    ENV["PREFIX"] = prefix
    ENV["JANET_BUILD"] = "\\\"homebrew\\\""
    ENV["JANET_PATH"] = syspath

    system "make"
    system "make", "install"

    resource("jpm").stage do
      (libexec/"jpm").install Dir["*"]
    end
  end

  post_install_steps do
    mkdir_p "{{HOMEBREW_PREFIX}}/lib/janet"
    run "janet", args: ["bootstrap.janet"], base: :bin, chdir: "{{libexec}}/jpm",
         env: {
           "PREFIX"           => "{{prefix}}",
           "JANET_BINPATH"    => "{{HOMEBREW_PREFIX}}/bin",
           "JANET_HEADERPATH" => "{{HOMEBREW_PREFIX}}/include/janet",
           "JANET_LIBPATH"    => "{{HOMEBREW_PREFIX}}/lib",
           "JANET_MANPATH"    => "{{HOMEBREW_PREFIX}}/share/man/man1",
           "JANET_MODPATH"    => "{{HOMEBREW_PREFIX}}/lib/janet",
         }
  end

  def caveats
    <<~EOS
      When uninstalling Janet, please delete the following manually:
      - #{HOMEBREW_PREFIX}/lib/janet
      - #{HOMEBREW_PREFIX}/bin/jpm
      - #{HOMEBREW_PREFIX}/share/man/man1/jpm.1
    EOS
  end

  test do
    janet = bin/"janet"
    jpm = HOMEBREW_PREFIX/"bin/jpm"
    assert_equal "12", shell_output("#{janet} -e '(print (+ 5 7))'").strip
    assert_path_exists jpm, "jpm must exist"
    assert_predicate jpm, :executable?, "jpm must be executable"
    assert_match syspath.to_s, shell_output("#{jpm} show-paths")
  end
end
