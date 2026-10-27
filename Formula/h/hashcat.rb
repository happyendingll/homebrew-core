class Hashcat < Formula
  desc "World's fastest and most advanced password recovery utility"
  homepage "https://hashcat.net/hashcat/"
  url "https://hashcat.net/files/hashcat-8.0.0.tar.gz"
  mirror "https://github.com/hashcat/hashcat/archive/refs/tags/v8.0.0.tar.gz"
  sha256 "d6a7533e1e250a236a8b99d0b725cdd76d8fdce744c7eeacb2bf42210fe4761b"
  license all_of: [
    "MIT",
    "LZMA-SDK-9.22", # deps/LZMA-SDK/
    :public_domain,  # include/sort_r.h
  ]
  version_scheme 1
  head "https://github.com/hashcat/hashcat.git", branch: "master"

  livecheck do
    url :homepage
    regex(/href=.*?hashcat[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 sequoia: "eb4d5b8b3f8e1e9052e647912547c7d75dc06cb786f2a47e657f69abd12068a5"
  end

  depends_on "minizip"
  depends_on "xxhash"

  uses_from_macos "python"

  on_macos do
    depends_on "gnu-sed" => :build
  end

  on_linux do
    depends_on "opencl-headers" => :build
    depends_on "opencl-icd-loader"
    depends_on "pocl"
    depends_on "zlib-ng-compat"
  end

  def install
    # Remove some bundled dependencies that are not needed
    (buildpath/"deps").each_child do |dep|
      rm_r(dep) if %w[OpenCL-Headers unrar xxHash zlib].include?(dep.basename.to_s)
    end
    # The ZC706 bootloader is board firmware, so retain its redistribution notices.
    (buildpath/"docs/license_libs").each_child do |dep|
      rm(dep) unless %w[SSE2NEON LZMA XILINX_FSBL].any? { |dep_name| dep.basename.to_s.start_with?(dep_name) }
    end

    args = %W[
      CC=#{ENV.cc}
      COMPTIME=#{ENV["SOURCE_DATE_EPOCH"]}
      PREFIX=#{prefix}
      USE_SYSTEM_XXHASH=1
      USE_SYSTEM_OPENCL=1
      USE_SYSTEM_ZLIB=1
      ENABLE_UNRAR=0
    ]
    system "make", *args
    system "make", "install", *args
    mv bin/"hashcat", bin/"hashcat_bin"
    (bin/"hashcat").write_env_script bin/"hashcat_bin", XDG_DATA_HOME: share
  end

  test do
    ENV["XDG_CACHE_HOME"] = testpath
    ENV["XDG_DATA_HOME"] = testpath
    (testpath/"hashcat").mkpath

    # OpenCL is not supported on virtualized arm64 macOS
    # Metal on macOS 27 doesn't seem to work yet
    no_opencl = OS.mac? && Hardware::CPU.virtualized?
    no_metal = !OS.mac? || MacOS.version >= :golden_gate

    args = %w[
      --benchmark
      --hash-type=0
      --workload-profile=2
    ]
    args << (no_opencl ? "--backend-ignore-opencl" : "--opencl-device-types=1,2")
    args << "--backend-ignore-metal" if OS.mac? && no_metal

    if no_opencl && no_metal
      no_platform_message = "No OpenCL, Metal, HIP or CUDA compatible platform found"
      assert_match no_platform_message, shell_output("#{bin}/hashcat_bin #{args.join(" ")} 2>&1", 255)
    else
      assert_match "Hash-Mode 0 (MD5)", shell_output("#{bin}/hashcat_bin #{args.join(" ")}")
    end

    assert_match version.to_s, shell_output("#{bin}/hashcat_bin --version")
  end
end
