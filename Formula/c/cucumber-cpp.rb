class CucumberCpp < Formula
  desc "Support for writing Cucumber step definitions in C++"
  homepage "https://cucumber.io"
  url "https://github.com/cucumber/cucumber-cpp.git",
      tag:      "v0.9.0",
      revision: "3a906521e53846b4c5d59b994e4b60655097d5ea"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "3766f83d08a802eaa3f073d714efba1d26142518aa36d71a0a93dab9b07f3e5e"
  end

  depends_on "cmake" => :build
  depends_on "nlohmann-json" => :build
  depends_on "ruby" => :test
  depends_on "asio"
  depends_on "tclap"

  allow_network_access! :test

  def install
    args = %w[
      -DBUILD_SHARED_LIBS=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    doc.install "examples"
  end

  test do
    ENV.prepend_path "PATH", formula_opt_bin("ruby")
    ENV["GEM_HOME"] = testpath
    ENV["BUNDLE_PATH"] = testpath

    system "gem", "install", "cucumber:9.2.1", "cucumber-wire:7.0.0", "--no-document"

    (testpath/"features/test.feature").write <<~CUCUMBER
      Feature: Test
        Scenario: Just for test
          Given A given statement
          When A when statement
          Then A then statement
    CUCUMBER
    (testpath/"features/step_definitions/cucumber.wire").write <<~EOS
      host: localhost
      port: 3902
    EOS
    (testpath/"features/support/wire.rb").write <<~RUBY
      require 'cucumber/wire'
    RUBY
    (testpath/"test.cpp").write <<~CPP
      #include <cucumber-cpp/generic.hpp>
      GIVEN("^A given statement$") {
      }
      WHEN("^A when statement$") {
      }
      THEN("^A then statement$") {
      }
    CPP

    system ENV.cxx, "-std=c++17", "test.cpp", "-o", "test", "-I#{include}", "-L#{lib}", "-lcucumber-cpp", "-pthread"

    begin
      pid = spawn "./test"
      sleep 1
      expected = <<~EOS
        Feature: Test

          Scenario: Just for test
            Given A given statement
            When A when statement
            Then A then statement

        1 scenario (1 passed)
        3 steps (3 passed)
      EOS
      assert_match expected, shell_output("#{testpath}/bin/cucumber --quiet")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
