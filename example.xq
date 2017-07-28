xquery version "3.1";

declare namespace functx = "http://www.functx.com";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace sparql = "http://www.w3.org/2005/sparql-results#";

import module namespace gitarclog = "http://jeffreycwitt.com/ns/xquery/gitarclog" at "logChanges.xq";
import module namespace gitarc= "http://joewiz.org/ns/xquery/gitarc" at "get-github-zip-archive.xq";

declare function local:replaceCollection($owner, $repo, $access_token) {
    (: these two lines could become their own function so that other apis like bitbucket could support it :)
    let $archive-url := gitarc:getArchiveUrl($owner, $repo, $access_token)
    let $parent-collection := "/db/apps/scta-data/"
    return
        gitarc:get-github-archive($archive-url, $parent-collection, $repo)

};


(: received post payload from github webook :)
let $post_data := request:get-data()
(: parse json payload :)
let $new_data := util:binary-to-string($post_data)
let $parsed_data := parse-json($new_data)
(: get before and after commit hashes :)
let $before := $parsed_data?before
let $after := $parsed_data?after
(: get name of owner and repo firing webhook :)
let $repo := $parsed_data?repository?name
let $owner := $parsed_data?repository?owner?name
let $pushed-at := $parsed_data?repository?pushed_at
(: get app access_token from environment :)
let $access_token := environment-variable("GH_ACCESS_TOKEN")
let $branch := $parsed_data?ref
let $url := "https://api.github.com/repos/" || $owner ||"/" || $repo || "/compare/" || $before ||"..." || $after || "?access_token=" || $access_token

return
  if ($branch = "refs/heads/master") then
    <div>
      {local:replaceCollection($owner, $repo, $access_token)}
      {gitarclog:log($before, $after, $owner, $repo, $pushed-at, $new_data, $access_token)}
    </div>
    else
    <div>
      <p>{$url}</p>
      <p>Push Event Not on Master Branch, No Action Taken</p>
    </div>
