{ writeShellApplication
, pandoc
}:
writeShellApplication {
  name = "slides";
    runtimeInputs = [
      pandoc
    ];
  text = ''
    pandoc \
      --standalone \
      --slide-level 2 \
      --to revealjs \
      --incremental \
      --include-in-header=${./slides.css} \
      --variable revealjs-url=${./reveal.js} \
      --variable theme=simple \
      "''${1:-${./slides.md}}"
  '';
}
