xquery version "3.1";


module namespace gitarclog = "http://jeffreycwitt.com/ns/xquery/gitarclog";
import module namespace http="http://expath.org/ns/http-client";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

declare function gitarclog:log($before, $after, $owner, $repo, $pushed-at, $new_data, $access_token){

  (: TODO response data not yet being used :)
  let $url := "https://api.github.com/repos/" || $owner ||"/" || $repo || "/compare/" || $before ||"..." || $after || "?access_token=" || $access_token
  let $request := <http:request method="GET" href="{$url}" timeout="30"/>
  let $response := http:send-request($request)

  let $filename := "pushEvent-" || $pushed-at || ".xml"
  let $new-content := "<logs><log>Push completed for commit " || $after || " for " || $owner || "/" || $repo || "</log></logs>"
  (: let $new-content := $new_data :)
  return
      <p>{xmldb:store('/db/apps/logs/', $filename, $new-content)}</p>
};
