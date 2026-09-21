class Flatcc < Formula
  desc "FlatBuffers Compiler and Library in C for C"
  homepage "https://github.com/dvidelabs/flatcc"
  url "https://github.com/dvidelabs/flatcc/archive/refs/tags/v0.6.4.tar.gz"
  sha256 "463c1cbc95777a01e103a6c961325f28e8876cb44a195b5c0f8d1117ae019580"
  license "Apache-2.0"
  head "https://github.com/dvidelabs/flatcc.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "8fa55ca38cecfe3b10052692cc3ce825a56050f8bfbea2a4685126b2ff7021b7"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    args = %W[
      -DFLATCC_INSTALL=ON
      -DFLATCC_INSTALL_LIB=#{lib}
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]
    # Workaround to build with CMake 4
    args << "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.fbs").write <<~EOS
      // example IDL file

      namespace MyGame.Sample;

      enum Color:byte { Red = 0, Green, Blue = 2 }

      union Any { Monster }  // add more elements..

        struct Vec3 {
          x:float;
          y:float;
          z:float;
        }

        table Monster {
          pos:Vec3;
          mana:short = 150;
          hp:short = 100;
          name:string;
          friendly:bool = false (deprecated);
          inventory:[ubyte];
          color:Color = Blue;
        }

      root_type Monster;

    EOS

    system bin/"flatcc", "-av", "--json", "test.fbs"
  end
end
