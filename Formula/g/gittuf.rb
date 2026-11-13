class Gittuf < Formula
  desc "Security layer for Git repositories"
  homepage "https://gittuf.dev/"
  url "https://github.com/gittuf/gittuf/releases/download/v0.18.0/gittuf.src.tar.gz"
  sha256 "feb0b809fd9deb6a846c1839e714a2739b7219241fbc2c03ba37b3fdfcef4cc7"
  license "Apache-2.0"
  head "https://github.com/gittuf/gittuf.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "7ec8145ceb58379b2d1e5763623ba5db81a75108dc81ef50ecce0422e3e14ebb"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/gittuf/gittuf/internal/version.gitVersion=#{version}"
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"gittuf", shell_parameter_format: :cobra)
  end

  test do
    system "git", "init"

    output = shell_output("#{bin}/gittuf policy init 2>&1", 1)
    assert_match(
      /Error: (required flag "signing-key" not set|signing key not specified in Git configuration)/,
      output,
    )

    output = shell_output("#{bin}/gittuf sync 2>&1", 1)
    assert_match "Error:", output
    assert_match(/(unable to identify git directory for repository|No such remote 'origin')/, output)

    assert_match version.to_s, shell_output("#{bin}/gittuf version")
  end
end
