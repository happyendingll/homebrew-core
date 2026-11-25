class Etcd < Formula
  desc "Key value store for shared configuration and service discovery"
  homepage "https://etcd.io"
  url "https://github.com/etcd-io/etcd.git",
      tag:      "v3.7.4",
      revision: "2e8a5c99e4982c8d4c521be15364ea4c5c68a489"
  license "Apache-2.0"
  compatibility_version 1
  head "https://github.com/etcd-io/etcd.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "e4b6a40707f5bb1d433a593efa38b550ba2c30976d7ed742f5637eabf3b1adf8"
  end

  depends_on "go" => :build

  # `test do` block runs a local etcd server
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "make", "build"
    bin.install Dir[buildpath/"bin/*"]
  end

  service do
    environment_variables ETCD_UNSUPPORTED_ARCH: "arm64" if Hardware::CPU.arm?
    run [opt_bin/"etcd"]
    run_type :immediate
    keep_alive true
    working_dir var
  end

  test do
    test_string = "Hello from brew test!"
    with_test_process(bin/"etcd", "--force-new-cluster", "--logger=zap", "--data-dir=#{testpath}") do
      sleep 10

      key_base64 = ["brew_test"].pack("m0")
      value_base64 = [test_string].pack("m0")

      # PUT the key using the v3 API
      put_payload = { key: key_base64, value: value_base64 }.to_json
      system "curl", "-L", "http://127.0.0.1:2379/v3/kv/put", "-X", "POST", "-d", put_payload

      # GET the key back
      get_payload = { key: key_base64 }.to_json
      curl_output = shell_output("curl -L http://127.0.0.1:2379/v3/kv/range -X POST -d '#{get_payload}'")
      response_hash = JSON.parse(curl_output)

      retrieved_value_base64 = response_hash.dig("kvs", 0, "value")
      retrieved_value = retrieved_value_base64.unpack1("m")

      assert_equal test_string, retrieved_value

      assert_equal "OK\n", shell_output("#{bin}/etcdctl put foo bar")
      assert_equal "foo\nbar\n", shell_output("#{bin}/etcdctl get foo 2>&1")
    end
  end
end
