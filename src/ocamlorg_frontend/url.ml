let index = "/"

let learn = "/learn"

let packages = "/packages"

let packages_search = "/packages/search"

let package v = "/p/" ^ v

let package_with_univ hash v = "/u/" ^ hash ^ "/" ^ v

let package_with_version v version = "/p/" ^ v ^ "/" ^ version

let package_with_hash_with_version hash v version =
  "/u/" ^ hash ^ "/" ^ v ^ "/" ^ version

let package_toplevel v version = "/p/" ^ v ^ "/" ^ version ^ "/toplevel"

let package_toplevel_with_hash hash v version =
  "/u/" ^ hash ^ "/" ^ v ^ "/" ^ version ^ "/toplevel"

let package_doc v version = "/p/" ^ v ^ "/" ^ version ^ "/doc/" ^ "**"

let package_doc_with_hash hash v version =
  "/u/" ^ hash ^ "/" ^ v ^ "/" ^ version ^ "/doc/" ^ "**"

let community = "/community"

let success_stories = "/success-stories"

let success_story v = "/success-stories/" ^ v

let industrial_users = "/industrial-users"

let academic_users = "/academic-users"

let about = "/about"

let manual = "/manual/index.html"

let manual_with_version v = "/manual/" ^ v

let books = "/books"

let releases = "/releases"

let release v = "/releases/" ^ v

let events = "/events"

let event v = "/events/" ^ v

let blog = "/blog"

let opportunities = "/opportunities"

let opportunity v = "/opportunities/" ^ v

let carbon_footprint = "/carbon-footprint"

let privacy = "/privacy"

let terms = "/terms"

let papers = "/papers"

let tutorial name = "/learn/" ^ name

let getting_started = "/learn/up-and-running"

let best_practices = "/learn/best-practices"

let problems = "/problems"