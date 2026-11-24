class Anpdf < Formula
  desc "Local, contract-validated, agent-native PDF toolkit"
  homepage "https://github.com/nextexcite/anPDF"
  url "https://github.com/nextexcite/anPDF/releases/download/v0.4.4/anpdf-0.4.4-macos-arm64.tar.gz"
  sha256 "9c85e6c97ad4b6dce2f4e4f75a882bcb70e31f86d79c7d3e254f893dbd2f3a46"
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
      %PDF-1.3
      %#### 
      1 0 obj
      <<
      /Producer (pypdf)
      >>
      endobj
      2 0 obj
      <<
      /Type /Pages
      /Count 1
      /Kids [ 4 0 R ]
      >>
      endobj
      3 0 obj
      <<
      /Type /Catalog
      /Pages 2 0 R
      >>
      endobj
      4 0 obj
      <<
      /Type /Page
      /Resources <<
      /Font <<
      /F1 6 0 R
      >>
      >>
      /MediaBox [ 0.0 0.0 612 792 ]
      /Parent 2 0 R
      /Contents 5 0 R
      >>
      endobj
      5 0 obj
      <<
      /Length 33
      >>
      stream
      BT /F1 24 Tf 72 700 Td (Hi) Tj ET
      endstream
      endobj
      6 0 obj
      <<
      /Type /Font
      /Subtype /Type1
      /BaseFont /Helvetica
      >>
      endobj
      xref
      0 7
      0000000000 65535 f 
      0000000015 00000 n 
      0000000054 00000 n 
      0000000113 00000 n 
      0000000162 00000 n 
      0000000294 00000 n 
      0000000377 00000 n 
      trailer
      <<
      /Size 7
      /Root 3 0 R
      /Info 1 0 R
      >>
      startxref
      447
      %%EOF
    EOS
    out = shell_output("#{bin}/anpdf render-page --root #{testpath} --request-json '{\"input\":{\"path\":\"page.pdf\"},\"page\":1,\"output\":{\"path\":\"page.png\"}}'")
    assert_match "renderPage", out
    assert_predicate testpath/"page.png", :exist?
  end
end
