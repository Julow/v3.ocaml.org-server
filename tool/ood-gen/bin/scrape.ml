open Cmdliner
open Ood_gen

let term_scrapers =
  [
    ("planet", Blog.Scraper.scrape);
    ("video", Video.scrape);
    ("changelog", Changelog.Scraper.scrape);
  ]

let cmds =
  Cmd.group (Cmd.info "ood-scrape")
  @@ List.map
       (fun (term, scraper) ->
         Cmd.v (Cmd.info term) Term.(const scraper $ const ()))
       term_scrapers

let () =
  Printexc.record_backtrace true;
  exit (Cmd.eval cmds)
