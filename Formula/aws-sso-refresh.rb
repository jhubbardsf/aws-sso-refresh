class AwsSsoRefresh < Formula
  desc "Automatically refresh AWS SSO sessions before they expire"
  homepage "https://github.com/jhubbardsf/aws-sso-refresh"
  url "https://github.com/jhubbardsf/aws-sso-refresh/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "ddabc79716df7c6fab8bcdf6ab44b066e68e1b64abbb12eb3e65422abc299dc7"
  license "MIT"
  head "https://github.com/jhubbardsf/aws-sso-refresh.git", branch: "main"

  depends_on "bash" => "4.0"
  depends_on "jq"
  depends_on "awscli"

  def install
    bin.install "bin/aws-sso-refresh"
  end

  def caveats
    <<~EOS
      To enable automatic background refresh:
        aws-sso-refresh install

      To check your SSO session status:
        aws-sso-refresh status

      The daemon will run every 10 minutes and refresh sessions
      that are within 30 minutes of expiring.
    EOS
  end

  test do
    assert_match "aws-sso-refresh v", shell_output("#{bin}/aws-sso-refresh version")
  end
end
