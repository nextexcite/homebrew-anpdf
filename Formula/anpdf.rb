class Anpdf < Formula
  desc "Local, contract-validated, agent-native PDF toolkit"
  homepage "https://github.com/nextexcite/anPDF"
  url "https://github.com/nextexcite/anPDF/releases/download/v0.3.1/anpdf-0.3.1-macos-arm64.tar.gz"
  sha256 "d6722535f3af7274ecc2b20535f15f4e118fb90b7d7a58c447db8bf645b59ed0"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on :macos
  depends_on "qpdf"

  def install
    bin.install "anpdf"
    doc.install "license-manifest.json"
    (doc/"THIRD_PARTY_LICENSES").install Dir["THIRD_PARTY_LICENSES/*"]
    generate_completions_from_executable(bin/"anpdf", "completions")
  end

  test do
    assert_match "anpdf #{version}", shell_output("#{bin}/anpdf --version")
    assert_match "inspectPdf", shell_output("#{bin}/anpdf operations")
    assert_match "_anpdf", shell_output("#{bin}/anpdf completions bash")
  end
end
