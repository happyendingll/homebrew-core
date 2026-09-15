class Bluetoothconnector < Formula
  desc "Connect and disconnect Bluetooth devices"
  homepage "https://github.com/lapfelix/BluetoothConnector"
  url "https://github.com/lapfelix/BluetoothConnector/archive/refs/tags/2.1.0.tar.gz"
  sha256 "cbb192e5f94da27408bd8306a25e11bbffd643d916f6a03d532f83a229281f77"
  license "MIT"
  head "https://github.com/lapfelix/BluetoothConnector.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "64871b447abfdf8c669734600244ed3e569a968a86e7b9c6f9fbfe37cdb1edcd"
  end

  depends_on :macos

  uses_from_macos "swift" => :build, since: :ventura # swift 5.9+

  def install
    system "swift", "build", *std_swift_args
    bin.install ".build/release/BluetoothConnector"
  end

  test do
    if ENV["HOMEBREW_GITHUB_ACTIONS"]
      # OS privacy restrictions may block the process on the Bluetooth permission prompt,
      # so only check the usage exit code when it actually ran to completion.
      pid = spawn bin/"BluetoothConnector"
      sleep 5
      if Process.wait(pid, Process::WNOHANG)
        assert_equal 64, $CHILD_STATUS.exitstatus
      else
        Process.kill("TERM", pid)
        Process.wait(pid)
      end
    else
      shell_output("#{bin}/BluetoothConnector", 64)
      output_fail = shell_output("#{bin}/BluetoothConnector --connect 00-00-00-00-00-00", 252)
      assert_equal "Not paired to device\n", output_fail
    end
  end
end
