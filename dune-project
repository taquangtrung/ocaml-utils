(lang dune 2.9)

(name outils)
(version 0.0.1)
(authors "Ta Quang Trung")
(maintainers "Ta Quang Trung")
(bug_reports "https://github.com/taquangtrung/ocaml-utils/issues")
(homepage "https://github.com/taquangtrung/ocaml-utils")

;; Run `dune build` to generate `.opam` file
(generate_opam_files true)

(package
 (name outils)
 (synopsis "An extended library of the OCaml Core standard library.")
 (description "This library is a collection of additionally useful OCaml functions, which are implemented on top of the OCaml Core library.")
 (depends (core (>= 0.14.1))
          dune))
