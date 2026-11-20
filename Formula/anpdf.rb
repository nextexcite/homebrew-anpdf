class Anpdf < Formula
  desc "Local, contract-validated, agent-native PDF toolkit"
  homepage "https://github.com/nextexcite/anPDF"
  url "https://github.com/nextexcite/anPDF/releases/download/v0.3.2/anpdf-0.3.2-macos-arm64.tar.gz"
  sha256 "cf6aff6548a34b2300a992bb801760b8e19086f87004fece074fa43b65018eb4"
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
