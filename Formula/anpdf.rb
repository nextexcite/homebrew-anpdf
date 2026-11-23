class Anpdf < Formula
  desc "Local, contract-validated, agent-native PDF toolkit"
  homepage "https://github.com/nextexcite/anPDF"
  url "https://github.com/nextexcite/anPDF/releases/download/v0.4.0/anpdf-0.4.0-macos-arm64.tar.gz"
  sha256 "0ba2ef004515117c0f0b691d3a8f6a834d159cf6448c81ade06c144dc9ada24f"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on :macos
  depends_on "qpdf"

  def install
    bin.install "anpdf"
    # Release bundles libpdfium.dylib; the binary resolves it at
    # <exe>/../lib/anpdf/libpdfium.dylib before falling back to exe-adjacent.
    (lib/"anpdf").install "libpdfium.dylib"
    doc.install "license-manifest.json"
    (doc/"THIRD_PARTY_LICENSES").install Dir["THIRD_PARTY_LICENSES/*"]
    (doc/"PDFIUM_LICENSES").install Dir["PDFIUM_LICENSES/*"]
    generate_completions_from_executable(bin/"anpdf", "completions")
  end

  test do
    assert_match "anpdf #{version}", shell_output("#{bin}/anpdf --version")
    assert_match "inspectPdf", shell_output("#{bin}/anpdf operations")
    assert_match "_anpdf", shell_output("#{bin}/anpdf completions bash")
    # Renderer-backed operation: proves the installed layout exposes libpdfium.
    (testpath/"page.pdf").binwrite <<~EOS
      %PDF-1.4
      1 0 obj
      <</Type/Catalog/Pages 2 0 R>>
      endobj
      2 0 obj
      <</Type/Pages/Kids[3 0 R]/Count 1>>
      endobj
      3 0 obj
      <</Type/Page/Parent 2 0 R/MediaBox[0 0 612 792]/Contents 4 0 R/Resources<</Font<</F1<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>>>>>>
      endobj
      4 0 obj
      <</Length 33>>
      stream
      BT /F1 24 Tf 72 700 Td (Hi) Tj ET
      endstream
      endobj
      xref
      0 5
      0000000000 65535 f
      0000000009 00000 n
      0000000054 00000 n
      0000000105 00000 n
      0000000257 00000 n
      trailer
      <</Size 5/Root 1 0 R>>
      startxref
      338
      %%EOF
    EOS
    out = shell_output("#{bin}/anpdf renderPage --root #{testpath} --request-json '{\"input\":{\"path\":\"page.pdf\"},\"page\":1,\"output\":{\"path\":\"page.png\"}}'")
    assert_match "renderPage", out
    assert_predicate testpath/"page.png", :exist?
  end
end
