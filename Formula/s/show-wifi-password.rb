class ShowWifiPassword < Formula
  desc "Fetches the current WiFi password from the macOS Keychain"
  homepage "https://github.com/ggfevans/show-wifi-password"
  url "https://github.com/ggfevans/show-wifi-password/releases/tag/v1.0.0"
  sha256 "af4766fd8159c99472214d465a2f1d11a443e6af510c4336de5f494b2bbfce51"
  license "MIT"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, all: "a253b554c4b811b489e3a487f6472ab8c5b4f8df34d203ed5deab3776cd4ec1f"
  end

  depends_on :macos
  
  def install
    bin.install "show-wifi-password.sh" => "show-wifi-password"
  end

  test do
    assert_match "Show WiFi Password", shell_output("#{bin}/show-wifi-password -v")
    assert_match "Usage:", shell_output("#{bin}/show-wifi-password -h")
  end
end
