open Import

let not_found _req = Dream.html ~code:404 (Ocamlorg_frontend.not_found ())

let index _req = Dream.html (Ocamlorg_frontend.home ())

let learn _req =
  let papers =
    Ood.Paper.all |> List.filter (fun (paper : Ood.Paper.t) -> paper.featured)
  in
  let books =
    Ood.Book.all |> List.filter (fun (book : Ood.Book.t) -> book.featured)
  in
  let release = List.hd Ood.Release.all in
  Dream.html (Ocamlorg_frontend.learn ~papers ~books ~release)

let community _req = Dream.html (Ocamlorg_frontend.community ())

let success_stories _req =
  let stories = Ood.Success_story.all () in
  Dream.html (Ocamlorg_frontend.success_stories stories)

let success_story req =
  let slug = Dream.param "id" req in
  let story = Ood.Success_story.get_by_slug slug in
  match story with
  | Some story ->
    Dream.html (Ocamlorg_frontend.success_story story)
  | None ->
    not_found req

let industrial_users _req =
  let users =
    Ood.Industrial_user.all ()
    |> List.filter (fun (item : Ood.Industrial_user.t) -> item.featured)
  in
  Dream.html (Ocamlorg_frontend.industrial_users users)

let academic_users req =
  let search_user pattern t =
    let open Ood.Academic_institution in
    let pattern = String.lowercase_ascii pattern in
    let name_is_s { name; _ } = String.lowercase_ascii name = pattern in
    let name_contains_s { name; _ } =
      String.contains_s (String.lowercase_ascii name) pattern
    in
    let score user =
      if name_is_s user then
        -1
      else if name_contains_s user then
        0
      else
        failwith "impossible user score"
    in
    t
    |> List.filter (fun p -> name_contains_s p)
    |> List.sort (fun user_1 user_2 -> compare (score user_1) (score user_2))
  in
  let users =
    match Dream.query "q" req with
    | None ->
      Ood.Academic_institution.all ()
    | Some search ->
      search_user search (Ood.Academic_institution.all ())
  in
  let users =
    match Dream.query "c" req with
    | None ->
      users
    | Some continent ->
      List.filter
        (fun user -> user.Ood.Academic_institution.continent = continent)
        users
  in
  Dream.html (Ocamlorg_frontend.academic_users users)

let about _req = Dream.html (Ocamlorg_frontend.about ())

let manual _req = Dream.html (Ocamlorg_frontend.manual ())

let books _req =
  let books =
    Ood.Book.all |> List.filter (fun (item : Ood.Book.t) -> item.featured)
  in
  Dream.html (Ocamlorg_frontend.books books)

let releases req =
  let search_release pattern t =
    let open Ood.Release in
    let pattern = String.lowercase_ascii pattern in
    let version_is_s { version; _ } =
      String.lowercase_ascii version = pattern
    in
    let version_contains_s { version; _ } =
      String.contains_s (String.lowercase_ascii version) pattern
    in
    let body_contains_s { body_md; _ } =
      String.contains_s (String.lowercase_ascii body_md) pattern
    in
    let score release =
      if version_is_s release then
        -1
      else if version_contains_s release then
        0
      else if body_contains_s release then
        2
      else
        failwith "impossible release score"
    in
    t
    |> List.filter (fun p -> version_contains_s p)
    |> List.sort (fun release_1 release_2 ->
           compare (score release_1) (score release_2))
  in
  let search = Dream.query "q" req in
  let releases =
    match search with
    | None ->
      Ood.Release.all
    | Some search ->
      search_release search Ood.Release.all
  in
  Dream.html (Ocamlorg_frontend.releases releases)

let release req =
  let version = Dream.param "id" req in
  match Ood.Release.get_by_version version with
  | Some release ->
    Dream.html (Ocamlorg_frontend.release release)
  | None ->
    not_found req

let events _req =
  let workshops = Ood.Workshop.all in
  let meetups = Ood.Meetup.all in
  Dream.html (Ocamlorg_frontend.events ~workshops ~meetups)

let workshop req =
  let watch_ocamlorg_embed =
    let presentations =
      List.concat_map
        (fun (w : Ood.Workshop.t) -> w.presentations)
        Ood.Workshop.all
    in
    let rec get_last = function
      | [] ->
        ""
      | [ x ] ->
        x
      | _ :: xs ->
        get_last xs
    in
    let watch =
      List.map
        (fun (w : Ood.Watch.t) ->
          String.split_on_char '/' w.embed_path |> get_last |> fun v -> v, w)
        Ood.Watch.all
    in
    let tbl = Hashtbl.create 100 in
    let add_video (p : Ood.Workshop.presentation) =
      match p.video with
      | Some video ->
        let uuid = String.split_on_char '/' video |> get_last in
        let find (v, w) = if String.equal uuid v then Some w else None in
        let w = List.find_map find watch in
        Option.iter (fun w -> Hashtbl.add tbl p.title w) w
      | None ->
        ()
    in
    List.iter add_video presentations;
    tbl
  in
  let slug = Dream.param "id" req in
  match
    List.find_opt (fun x -> x.Ood.Workshop.slug = slug) Ood.Workshop.all
  with
  | Some workshop ->
    Dream.html
      (Ocamlorg_frontend.workshop ~videos:watch_ocamlorg_embed workshop)
  | None ->
    not_found req

let blog _req = Dream.html (Ocamlorg_frontend.blog ())

let opportunities req =
  let search_job pattern t =
    let open Ood.Job in
    let pattern = String.lowercase_ascii pattern in
    let title_is_s { title; _ } = String.lowercase_ascii title = pattern in
    let title_contains_s { title; _ } =
      String.contains_s (String.lowercase_ascii title) pattern
    in
    let score job =
      if title_is_s job then
        -1
      else if title_contains_s job then
        0
      else
        failwith "impossible job score"
    in
    t
    |> List.filter (fun p -> title_contains_s p)
    |> List.sort (fun job_1 job_2 -> compare (score job_1) (score job_2))
  in
  let search = Dream.query "q" req in
  let jobs =
    match search with
    | None ->
      Ood.Job.all_not_fullfilled
    | Some search ->
      search_job search Ood.Job.all_not_fullfilled
  in
  let country = Dream.query "c" req in
  let jobs =
    match country with
    | None | Some "All" ->
      jobs
    | Some country ->
      List.filter (fun job -> job.Ood.Job.country = country) jobs
  in
  Dream.html (Ocamlorg_frontend.opportunities ?search ?country jobs)

let opportunity req =
  let id = Dream.param "id" req in
  match Option.bind (int_of_string_opt id) Ood.Job.get_by_id with
  | Some job ->
    Dream.html (Ocamlorg_frontend.opportunity job)
  | None ->
    not_found req

let carbon_footprint _req = Dream.html (Ocamlorg_frontend.carbon_footprint ())

let privacy _req = Dream.html (Ocamlorg_frontend.privacy ())

let terms _req = Dream.html (Ocamlorg_frontend.terms ())

let papers req =
  let search_paper pattern t =
    let open Ood.Paper in
    let pattern = String.lowercase_ascii pattern in
    let title_is_s { title; _ } = String.lowercase_ascii title = pattern in
    let title_contains_s { title; _ } =
      String.contains_s (String.lowercase_ascii title) pattern
    in
    let abstract_contains_s { abstract; _ } =
      String.contains_s (String.lowercase_ascii abstract) pattern
    in
    let has_tag_s { tags; _ } =
      List.exists
        (fun tag -> String.contains_s (String.lowercase_ascii tag) pattern)
        tags
    in
    let score paper =
      if title_is_s paper then
        -1
      else if title_contains_s paper then
        0
      else if has_tag_s paper then
        1
      else if abstract_contains_s paper then
        2
      else
        failwith "impossible paper score"
    in
    t
    |> List.filter (fun p -> title_contains_s p)
    |> List.sort (fun paper_1 paper_2 ->
           compare (score paper_1) (score paper_2))
  in
  let search = Dream.query "q" req in
  let papers =
    match search with
    | None ->
      Ood.Paper.all
    | Some search ->
      search_paper search Ood.Paper.all
  in
  let recommended_papers =
    Ood.Paper.all |> List.filter (fun (paper : Ood.Paper.t) -> paper.featured)
  in
  Dream.html (Ocamlorg_frontend.papers ?search ~recommended_papers papers)

let tutorial req =
  let slugify value =
    value
    |> Str.global_replace (Str.regexp " ") "-"
    |> String.lowercase_ascii
    |> Str.global_replace (Str.regexp "[^a-z0-9\\-]") ""
  in
  let slug = Dream.param "id" req in
  match
    List.find_opt
      (fun x -> slugify x.Ood.Tutorial.title = slug)
      Ood.Tutorial.all
  with
  | Some tutorial ->
    Ocamlorg_frontend.tutorial tutorial |> Dream.html
  | None ->
    not_found req

let best_practices _req =
  Dream.html (Ocamlorg_frontend.best_practices Ood.Workflow.all)

let problems _req = Dream.html (Ocamlorg_frontend.problems Ood.Problem.all)

type package_kind =
  | Package
  | Universe

let packages _req = Dream.html (Ocamlorg_frontend.packages [])

let package_to_search_result (p : Ocamlorg_package.t)
    : Ocamlorg_frontend.package_search_result
  =
  let name = Ocamlorg_package.(Name.to_string @@ name p) in
  let version = Ocamlorg_package.(Version.to_string @@ version p) in
  let info = Ocamlorg_package.info p in
  { name
  ; version
  ; description = info.synopsis
  ; tags = info.tags
  ; authors = List.map (fun t -> t.Ood.Opam_user.name) info.authors
  ; license = info.license
  }

let packages_search t req =
  match Dream.query "q" req with
  | Some search ->
    let packages = Ocamlorg_package.search_package t search in
    let total = List.length packages in
    let results = List.map package_to_search_result packages in
    Dream.html (Ocamlorg_frontend.packages_search ~total results)
  | None ->
    Dream.redirect req "/packages"

let package t req =
  let package = Dream.param "name" req in
  let find_default_version name =
    Ocamlorg_package.get_package_latest t name
    |> Option.map (fun pkg -> Ocamlorg_package.version pkg)
  in
  let name = Ocamlorg_package.Name.of_string package in
  let version = find_default_version name in
  match version with
  | Some version ->
    let target =
      "/p/" ^ package ^ "/" ^ Ocamlorg_package.Version.to_string version
    in
    Dream.redirect req target
  | None ->
    not_found req

let package_versioned t kind req =
  let name = Ocamlorg_package.Name.of_string @@ Dream.param "name" req in
  let version =
    Ocamlorg_package.Version.of_string @@ Dream.param "version" req
  in
  let package = Ocamlorg_package.get_package t name version in
  match package with
  | None ->
    not_found req
  | Some package ->
    let open Lwt.Syntax in
    let kind =
      match kind with
      | Package ->
        `Package
      | Universe ->
        `Universe (Dream.param "hash" req)
    in
    let description =
      (Ocamlorg_package.info package).Ocamlorg_package.Info.description
    in
    let* _readme =
      let+ readme_opt = Ocamlorg_package.readme_file ~kind package in
      Option.value
        readme_opt
        ~default:(description |> Omd.of_string |> Omd.to_html)
    in
    let _license = Ocamlorg_package.license_file ~kind package in
    let* _status = Ocamlorg_package.status ~kind package in
    let _versions =
      Ocamlorg_package.get_package_versions t name |> Option.value ~default:[]
    in
    let _toplevel = Ocamlorg_package.toplevel package in
    Dream.html (Ocamlorg_frontend.package_overview ())

let package_doc t kind req =
  let name = Ocamlorg_package.Name.of_string @@ Dream.param "name" req in
  let version =
    Ocamlorg_package.Version.of_string @@ Dream.param "version" req
  in
  let package = Ocamlorg_package.get_package t name version in
  match package with
  | None ->
    not_found req
  | Some package ->
    let open Lwt.Syntax in
    let kind =
      match kind with
      | Package ->
        `Package
      | Universe ->
        `Universe (Dream.param "hash" req)
    in
    let path = Dream.path req |> String.concat "/" in
    let _root =
      let make =
        match kind with
        | `Package ->
          Fmt.str "/p/%s/%s/doc/"
        | `Universe u ->
          Fmt.str "/u/%s/%s/%s/doc/" u
      in
      make
        (Ocamlorg_package.Name.to_string name)
        (Ocamlorg_package.Version.to_string version)
    in
    let* docs = Ocamlorg_package.documentation_page ~kind package path in
    let* _map = Ocamlorg_package.module_map ~kind package in
    let* _status = Ocamlorg_package.status ~kind package in
    (match docs with
    | None ->
      not_found req
    | Some doc ->
      let _description =
        (Ocamlorg_package.info package).Ocamlorg_package.Info.description
      in
      let _versions =
        Ocamlorg_package.get_package_versions t name |> Option.value ~default:[]
      in
      let canonical_module =
        doc.module_path
        |> List.map (function
               | Ocamlorg_package.Documentation.Module s ->
                 s
               | Ocamlorg_package.Documentation.ModuleType s ->
                 s
               | Ocamlorg_package.Documentation.FunctorArgument (_, s) ->
                 s)
        |> String.concat "."
      in
      let _title =
        match path with
        | "index.html" ->
          Printf.sprintf
            "Documentation · %s %s · OCaml Packages"
            (Ocamlorg_package.Name.to_string name)
            (Ocamlorg_package.Version.to_string version)
        | _ ->
          Printf.sprintf
            "%s · %s %s · OCaml Packages"
            canonical_module
            (Ocamlorg_package.Name.to_string name)
            (Ocamlorg_package.Version.to_string version)
      in
      let _toplevel = Ocamlorg_package.toplevel package in
      Dream.html (Ocamlorg_frontend.package_documentation ()))

let package_toplevel t kind req =
  let name = Ocamlorg_package.Name.of_string @@ Dream.param "name" req in
  let version =
    Ocamlorg_package.Version.of_string @@ Dream.param "version" req
  in
  let package = Ocamlorg_package.get_package t name version in
  match package with
  | None ->
    not_found req
  | Some package ->
    let toplevel = Ocamlorg_package.toplevel package in
    (match toplevel with
    | None ->
      not_found req
    | Some _toplevel ->
      let kind =
        match kind with
        | Package ->
          `Package
        | Universe ->
          `Universe (Dream.param "hash" req)
      in
      let open Lwt.Syntax in
      let* _status = Ocamlorg_package.status ~kind package in
      let _versions =
        Ocamlorg_package.get_package_versions t name |> Option.value ~default:[]
      in
      let _title =
        Printf.sprintf
          "Toplevel · %s %s · OCaml Packages"
          (Ocamlorg_package.Name.to_string name)
          (Ocamlorg_package.Version.to_string version)
      in
      let _description =
        Printf.sprintf
          "%s %s: %s"
          (Ocamlorg_package.Name.to_string name)
          (Ocamlorg_package.Version.to_string version)
          (Ocamlorg_package.info package).Ocamlorg_package.Info.description
      in
      Dream.html (Ocamlorg_frontend.package_toplevel ()))
