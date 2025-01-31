open Data_intf.Changelog

type metadata = {
  title : string;
  tags : string list;
  authors : string list option;
  description : string option;
  changelog : string option;
}
[@@deriving
  of_yaml,
    stable_record ~version:t ~remove:[ changelog; description ]
      ~modify:[ authors ]
      ~add:[ slug; changelog_html; body_html; body; date; project_name; version ]]

let of_metadata m = metadata_to_t m ~modify_authors:(Option.value ~default:[])

let re_slug =
  let open Re in
  let re_project_name =
    let w = rep1 alpha in
    seq [ w; rep (seq [ char '-'; w ]) ]
  in
  let re_version_string = seq [ digit; rep1 any ] in
  compile
    (seq
       [
         bos;
         seq
           [
             group (rep1 digit);
             char '-';
             group (rep1 digit);
             char '-';
             group (rep1 digit);
           ];
         char '-';
         opt
           (seq
              [ group re_project_name; set "-."; group re_version_string; eos ]);
       ])

let parse_slug s =
  match Re.exec_opt re_slug s with
  | None -> None
  | Some g ->
      let int n = Re.Group.get g n |> int_of_string in
      let year = int 1 in
      let month = int 2 in
      let day = int 3 in
      let version = Re.Group.get_opt g 5 in
      Some (Printf.sprintf "%04d-%02d-%02d" year month day, version)

let decode (fname, (head, body)) =
  let project_name = Filename.basename (Filename.dirname fname) in
  let slug = Filename.basename (Filename.remove_extension fname) in
  let metadata =
    metadata_of_yaml head |> Result.map_error (Utils.where fname)
  in
  let body_html =
    Cmarkit_html.of_doc ~safe:false
      (Hilite.Md.transform
         (Cmarkit.Doc.of_string ~strict:true (String.trim body)))
  in

  Result.map
    (fun metadata ->
      let changelog_html =
        match metadata.changelog with
        | None -> None
        | Some changelog ->
            Some
              (Cmarkit.Doc.of_string ~strict:true (String.trim changelog)
              |> Hilite.Md.transform
              |> Cmarkit_html.of_doc ~safe:false)
      in
      let date, version =
        match parse_slug slug with
        | Some x -> x
        | None ->
            failwith
              ("date is not present in metadata and could not be parsed from \
                slug: " ^ slug)
      in
      of_metadata ~slug ~changelog_html ~body ~body_html ~date ~project_name
        ~version metadata)
    metadata

let all () =
  Utils.map_md_files decode "changelog/*/*.md"
  |> List.sort (fun a b -> String.compare b.slug a.slug)

module ChangelogFeed = struct
  let create_entry (log : t) =
    let content = Syndic.Atom.Html (None, log.body_html) in
    let id = Uri.of_string ("https://ocaml.org/changelog/" ^ log.slug) in
    let authors = (Syndic.Atom.author "Ocaml.org", []) in
    let updated = Syndic.Date.of_rfc3339 (log.date ^ "T00:00:00-00:00") in
    Syndic.Atom.entry ~content ~id ~authors ~title:(Syndic.Atom.Text log.title)
      ~updated
      ~links:[ Syndic.Atom.link id ]
      ()

  let create_feed () =
    let open Rss in
    () |> all
    |> create_entries ~create_entry ~days:365
    |> entries_to_feed ~id:"changelog.xml" ~title:"OCaml Changelog"
    |> feed_to_string
end

let template () =
  Format.asprintf {ocaml|
include Data_intf.Changelog
let all = %a
|ocaml}
    (Fmt.brackets (Fmt.list pp ~sep:Fmt.semi))
    (all ())
