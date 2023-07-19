let index = "/"
let packages = "/packages"
let packages_search = "/packages/search"
let with_hash = function None -> "/p" | Some hash -> "/u/" ^ hash
let package ?hash v = with_hash hash ^ "/" ^ v
let package_docs v = "/p/" ^ v ^ "/doc"

let package_with_version ?hash v version =
  with_hash hash ^ "/" ^ v ^ "/" ^ version

let package_doc ?hash ?(page = "index.html") v version =
  with_hash hash ^ "/" ^ v ^ "/" ^ version ^ "/doc/" ^ page

let community = "/community"
let success_story v = "/success-stories/" ^ v
let industrial_users = "/industrial-users"
let academic_users = "/academic-users"
let about = "/about"
let manual v = "/manual/" ^ v
let api v = "/manual/api/" ^ v
let manual_latest = manual "latest"
let api_latest = api "latest"
let books = "/books"
let releases = "/releases"
let release v = "/releases/" ^ v
let workshop v = "/workshops/" ^ v
let blog = "/blog"
let news = "/news"
let news_post v = "/news/" ^ v
let jobs = "/jobs"
let carbon_footprint = "/carbon-footprint"
let privacy_policy = "/privacy-policy"
let governance = "/governance"
let playground = "/play"
let papers = "/papers"
let learn = "/docs"
let platform = "/docs/platform"
let ocaml_on_windows = "/docs/ocaml-on-windows"
let tutorial name = "/docs/" ^ name
let getting_started = tutorial "up-and-running"
let best_practices = "/docs/best-practices"
let problems = "/problems"
