class BazelAT8 < Formula
  desc "Google's own build tool"
  homepage "https://bazel.build/"
  url "https://github.com/bazelbuild/bazel/releases/download/8.8.1/bazel-8.8.1-dist.zip"
  sha256 "3c8784ad4f3d2ba6c6b2bbe424849886567ed644c491e9686d666e47efd13744"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(8(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "1edbb02be4ff83024dd55e7fdb489f00082a8e2cd5fe8a3d92c3c921e9a0b03c"
  end

  keg_only :versioned_formula

  # https://bazel.build/release#support-matrix
  deprecate! date: "2028-01-01", because: :unsupported
  disable! date: "2029-01-01", because: :unsupported

  depends_on "openjdk@21"

  uses_from_macos "python" => :build
  uses_from_macos "unzip"
  uses_from_macos "zip"

  on_linux do
    # We use a workaround to prevent modification of the `bazel-real` binary
    # but this means brew cannot rewrite paths for non-default prefix
    pour_bottle? only_if: :default_prefix

    on_arm do
      # Workaround for "/usr/bin/ld.gold: internal error in try_fix_erratum_843419_optimized"
      # Issue ref: https://sourceware.org/bugzilla/show_bug.cgi?id=31182
      depends_on "lld" => :build
    end
  end

  def bazel_real
    libexec/"bin/bazel-real"
  end

  def install
    java_home_env = Language::Java.java_home_env("21")

    ENV["EMBED_LABEL"] = "#{version}-homebrew"
    # Force Bazel ./compile.sh to put its temporary files in the buildpath
    ENV["BAZEL_WRKDIR"] = buildpath/"work"
    # Force Bazel to use brew OpenJDK
    extra_bazel_args = ["--tool_java_runtime_version=local_jdk"]
    if OS.mac?
      # Tools built for the exec configuration only follow `--host_macos_minimum_os`
      extra_bazel_args << "--macos_minimum_os=#{MacOS.version}.0"
      extra_bazel_args << "--host_macos_minimum_os=#{MacOS.version}.0"
    end
    ENV.merge! java_home_env.transform_keys(&:to_s)
    # Bazel clears environment variables which breaks superenv shims
    ENV.remove "PATH", Superenv.shims_path

    # Workaround to build zlib < 1.3.1 with Apple Clang 1700
    # https://releases.llvm.org/18.1.0/tools/clang/docs/ReleaseNotes.html#clang-frontend-potentially-breaking-changes
    # Issue ref: https://github.com/bazelbuild/bazel/issues/25124
    if DevelopmentTools.clang_build_version >= 1700
      extra_bazel_args += %w[--copt=-fno-define-target-os-macros --host_copt=-fno-define-target-os-macros]
    end

    # Set dynamic linker similar to cc shim so that bottle works on older Linux
    if OS.linux? && build.bottle? && ENV["HOMEBREW_DYNAMIC_LINKER"]
      extra_bazel_args << "--linkopt=-Wl,--dynamic-linker=#{ENV["HOMEBREW_DYNAMIC_LINKER"]}"
    end

    if OS.linux? && Hardware::CPU.arm64?
      extra_bazel_args << "--linkopt=-fuse-ld=lld"
      extra_bazel_args << "--host_linkopt=-fuse-ld=lld"
    end

    ENV["EXTRA_BAZEL_ARGS"] = extra_bazel_args.join(" ")

    (buildpath/"sources").install buildpath.children

    cd "sources" do
      system "./compile.sh"
      system "./output/bazel", "--output_user_root=#{buildpath}/output_user_root",
                               "build",
                               *extra_bazel_args,
                               "scripts:bash_completion",
                               "scripts:fish_completion"

      bin.install "scripts/packages/bazel.sh" => "bazel"
      ln_s bazel_real, bin/"bazel-#{version}"
      (libexec/"bin").install "output/bazel" => "bazel-real"
      bin.env_script_all_files libexec/"bin", java_home_env

      bash_completion.install "bazel-bin/scripts/bazel-complete.bash" => "bazel"
      zsh_completion.install "scripts/zsh_completion/_bazel"
      fish_completion.install "bazel-bin/scripts/bazel.fish"
    end

    # Workaround to avoid breaking the zip-appended `bazel-real` binary.
    # Can remove if brew correctly handles these binaries or if upstream
    # provides an alternative in https://github.com/bazelbuild/bazel/issues/11842
    if OS.linux? && build.bottle?
      Utils::Gzip.compress(bazel_real)
      bazel_real.write <<~SHELL
        #!/bin/bash
        echo 'ERROR: Need to run `brew postinstall #{name}`' >&2
        exit 1
      SHELL
      bazel_real.chmod 0755
    end
  end

  post_install_steps do
    install_gzipped_executable "bin/bazel-real.gz", "bin/bazel-real",
                                  source_base: :libexec, target_base: :libexec
  end

  test do
    touch testpath/"WORKSPACE"

    (testpath/"ProjectRunner.java").write <<~JAVA
      public class ProjectRunner {
        public static void main(String args[]) {
          System.out.println("Hi!");
        }
      }
    JAVA

    (testpath/"BUILD").write <<~STARLARK
      java_binary(
        name = "bazel-test",
        srcs = glob(["*.java"]),
        main_class = "ProjectRunner",
      )
    STARLARK

    # Explicitly disable repo contents cache
    system bin/"bazel", "build", "//:bazel-test", "--repo_contents_cache="
    assert_equal "Hi!\n", shell_output("bazel-bin/bazel-test")

    # Verify that `bazel` invokes Bazel's wrapper script, which delegates to
    # project-specific `tools/bazel` if present. Invoking `bazel-VERSION`
    # bypasses this behavior.
    (testpath/"tools/bazel").write <<~SHELL
      #!/bin/bash
      echo "stub-wrapper"
      exit 1
    SHELL
    (testpath/"tools/bazel").chmod 0755

    assert_equal "stub-wrapper\n", shell_output("#{bin}/bazel --version", 1)
    assert_equal "bazel #{version}-homebrew\n", shell_output("#{bin}/bazel-#{version} --version")
  end
end
