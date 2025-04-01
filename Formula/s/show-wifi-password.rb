class ShowWifiPassword < Formula
    desc "Simple macOS CLI tool to retrieve WiFi passwords from Keychain"
    homepage "https://github.com/ggfevans/show-wifi-password"
    url "https://github.com/ggfevans/show-wifi-password/archive/refs/tags/v1.0.0.tar.gz"
    sha256 "af4766fd8159c99472214d465a2f1d11a443e6af510c4336de5f494b2bbfce51"
    license "MIT"
  
    depends_on :macos
  
    def install
      bin.install "show-wifi-password.sh" => "show-wifi-password"
    end
  
    test do
      assert_match "Show WiFi Password", shell_output("#{bin}/show-wifi-password -v")
    end
  end