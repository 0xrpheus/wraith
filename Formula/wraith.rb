class Wraith < Formula
  desc "Silent network threat detection and host enumeration"
  homepage "https://github.com/0xrpheus/wraith"
  version "1.0.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/0xrpheus/wraith/releases/download/v1.0.0/wraith-macos-aarch64.tar.gz"
      sha256 "7982d3cc541b461a893b1dd270f750d0445e9cc6ea797689c8604ae5866a081e"
    end
    on_intel do
      url "https://github.com/0xrpheus/wraith/releases/download/v1.0.0/wraith-macos-x86_64.tar.gz"
      sha256 "6ce407249453be861b43b03a68a782b1bd396657d564cf1ed305ebc6a36bcafd"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/0xrpheus/wraith/releases/download/v1.0.0/wraith-linux-aarch64.tar.gz"
      sha256 "40ede9272e562a41336fac150ad7dda949473c2894c76d1b638ada54c7e465e0"
    end
    on_intel do
      url "https://github.com/0xrpheus/wraith/releases/download/v1.0.0/wraith-linux-x86_64.tar.gz"
      sha256 "d0dd7b655706479daacd4f6c52797dcfc99f7c6944a30e469e5e2b9511af4e89"
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
