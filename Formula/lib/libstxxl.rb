class Libstxxl < Formula
  desc "C++ implementation of STL for extra large data sets"
  homepage "https://stxxl.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/stxxl/stxxl/1.4.1/stxxl-1.4.1.tar.gz"
  sha256 "92789d60cd6eca5c37536235eefae06ad3714781ab5e7eec7794b1c10ace67ac"
  license "BSL-1.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "a1ae6c5337f7b2d54d332dce4cc4f08b05711b3ffb682fef01f5beb4a3312e0a"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :test

  deny_network_access!

  def install
    # Workaround to build with CMake 4
    args = %w[-DCMAKE_POLICY_VERSION_MINIMUM=3.5]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/".stxxl").write "disk=#{testpath}/stxxl.tmp,64MiB,syscall delete\n"
    (testpath/"test.cpp").write <<~CPP
      #include <iostream>
      #include <stxxl/vector>

      int main() {
        stxxl::VECTOR_GENERATOR<int>::result v;
        for (int i = 0; i < 1000; i++) v.push_back(i);
        std::cout << v.size() << " " << v[999] << std::endl;
        return 0;
      }
    CPP
    pkgconf_flags = shell_output("pkgconf --cflags --libs stxxl").chomp.split
    args = %w[-std=c++11 test.cpp -o test] + pkgconf_flags
    args += %w[-fopenmp -pthread] if OS.linux?
    system ENV.cxx, *args
    assert_match "1000 999", shell_output("./test")

    assert_match "sizeof(void*)", shell_output("#{bin}/stxxl_tool info")
  end
end
