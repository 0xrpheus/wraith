class Wraith < Formula
  desc "Silent network threat detection and host enumeration"
  homepage "https://github.com/0xrpheus/wraith"
  version "1.0.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/0xrpheus/wraith/releases/download/v1.0.0/wraith-macos-aarch64.tar.gz"
      sha256 "052fe180b62041443b76ca6676a5e75c9ba02774c46a4ca6777192dd0b43d52e"
    end
    on_intel do
      url "https://github.com/0xrpheus/wraith/releases/download/v1.0.0/wraith-macos-x86_64.tar.gz"
      sha256 "66956b1073f3ad1a8c842df90979cef965a11bd19292dd8f6fe6bcd09bf002b4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/0xrpheus/wraith/releases/download/v1.0.0/wraith-linux-aarch64.tar.gz"
      sha256 "66f04b4375025f9f3dc62dd52a829c40bd801f1a951aa89c585f928f9ac52a9e"
    end
    on_intel do
      url "https://github.com/0xrpheus/wraith/releases/download/v1.0.0/wraith-linux-x86_64.tar.gz"
      sha256 "e325e069a7aa5e22f4232e360e3a0cd1c1b5c32ceb4f8cb38592f47bcd358f08"
    end
  end

  def install
    # this detects which file exists in the extracted archive
    binary_name = OS.mac? ? "wraith-macos-#{Hardware::CPU.arch}" : "wraith-linux-#{Hardware::CPU.arch}"
    # then renames it to 'wraith' during the install into the bin folder
    bin.install binary_name => "wraith"
    man1.install "wraith.1"
  end

  test do
    assert_match "wraith 1.0.0", shell_output("#{bin}/wraith version")
  end
end
