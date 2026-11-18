class Flye < Formula
  include Language::Python::Virtualenv

  desc "De novo assembler for single molecule sequencing reads using repeat graphs"
  homepage "https://github.com/mikolmogorov/Flye"
  url "https://github.com/mikolmogorov/Flye/archive/refs/tags/2.9.7.tar.gz"
  sha256 "041635b3b7e7afc69fd50ab9cbf040db4749b04ae626ba65c8b08f550642351f"
  license all_of: [
    "BSD-3-Clause",
    "Apache-2.0", # lib/libcuckoo
    "BSL-1.0",    # lib/lemon
    "CC-BY-3.0",  # src/common/memory_info.h
    "MIT",        # lib/{interval_tree,minimap2}
  ]
  head "https://github.com/mikolmogorov/Flye.git", branch: "flye"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "8388547f335789e31769a22a2a3fbf78a4a101bbc0bc20a2ecf82b50fc74da33"
  end

  depends_on "python@3.15"
  depends_on "samtools"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    # Replace bundled samtools
    rm_r(Dir["lib/samtools*"])
    (buildpath/"bin").write_exec_script formula_opt_bin("samtools")/"samtools"
    (buildpath/"bin").install "bin/samtools" => "flye-samtools"
    chmod 0755, "bin/flye-samtools"

    # Workaround for arm64 Linux: https://github.com/mikolmogorov/Flye/pull/691
    ENV["arm_neon"] = ENV["aarch64"] = "1" if OS.linux? && Hardware::CPU.arm64?

    ENV.deparallelize
    venv = virtualenv_install_with_resources
    pkgshare.install_symlink venv.site_packages/"flye/tests/data"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/flye --version")
    system bin/"flye", "--pacbio-corr", pkgshare/"data/ecoli_500kb_reads_hifi.fastq.gz", "-o", testpath
    assert_path_exists "assembly.fasta"
  end
end
